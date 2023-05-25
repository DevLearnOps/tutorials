terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.37"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Project = "EmbracingChaosWeek"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#############################################################
# Systems Manager Parameters                                #
#############################################################
data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}
data "aws_ssm_parameter" "public_subnets" {
  name = "/vpc/public_subnets"
}
data "aws_ssm_parameter" "private_subnets" {
  name = "/vpc/private_subnets"
}

locals {
  name             = "embracing-chaos"
  application_name = "hello-chaos"
  container_port   = 8000
  container_image  = "${local.application_name}:v1"
  cpu              = 256
  memory           = 512
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.name
  base_registry    = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}

#############################################################
# Create application load balancer                          #
#############################################################
module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.name}-service"
  description = "Service security group"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Application = local.application_name
    Role        = "main-alb-secgroup"
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = local.name

  load_balancer_type = "application"

  vpc_id                = data.aws_ssm_parameter.vpc_id.value
  subnets               = split(",", data.aws_ssm_parameter.public_subnets.value)
  security_groups       = [module.alb_sg.security_group_id]
  create_security_group = false

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name             = "${local.name}-app"
      backend_protocol = "HTTP"
      backend_port     = local.container_port
      target_type      = "ip"
    },
  ]

  tags = {
    Application = local.application_name
    Role        = "main-alb"
  }
}

#############################################################
# Hello-chaos service definition                            #
#############################################################
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${local.name}-cluster"

  services = {
    app = {
      cpu           = local.cpu
      memory        = local.memory
      desired_count = 1
      launch_type   = "FARGATE"
      subnet_ids    = split(",", data.aws_ssm_parameter.private_subnets.value)

      container_definitions = {
        app = {
          essential = true
          image     = "${local.base_registry}/${local.container_image}"
          port_mappings = [
            {
              containerPort = local.container_port
              hostPort      = local.container_port
              protocol      = "tcp"
            },
          ]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = element(module.alb.target_group_arns, 0)
          container_name   = "app"
          container_port   = local.container_port
        }
      }

      security_group_rules = {
        alb_ingress_80 = {
          type        = "ingress"
          description = "Allow from LB to service port"
          from_port   = local.container_port
          to_port     = local.container_port
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        egress_vpc_cidr = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = {
    Application = local.application_name
  }
}

output "app_url" {
  value = "http://${module.alb.lb_dns_name}"
}
