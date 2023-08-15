########################################################################
#  Application Services
########################################################################
module "alb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${local.name}-alb-sg"
  description = "Application load balancer security group for ${var.application_name}"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = [module.vpc.vpc_cidr_block]
}

module "app_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.2.0"

  cluster_name = "${local.name}-cluster"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  for_each = {
    front = {
      internal          = false
      backend_port      = 8000
      health_check_path = "/health"
    }
    back = {
      internal          = true
      backend_port      = 8000
      health_check_path = "/health"
    }
  }
  name = "${local.name}-${each.key}-alb"

  load_balancer_type = "application"
  internal           = each.value.internal

  vpc_id          = module.vpc.vpc_id
  subnets         = each.value.internal ? module.vpc.private_subnets : module.vpc.public_subnets
  security_groups = [module.alb_security_group.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  target_groups = [
    {
      name             = "${local.name}-${each.key}"
      backend_protocol = "HTTP"
      backend_port     = each.value.backend_port
      target_type      = "ip"
      health_check = {
        matcher = "200,301,302"
        path    = try(each.value.health_check_path, "/")
      }
      deregistration_delay = 30
    },
  ]

}

module "service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.2.0"

  for_each = {
    front = {
      cpu            = 256
      memory         = 512
      min_containers = 1
      max_containers = 3
      container_port = 8000
      environment = [
        { "name" : "BACK_URL", "value" : "http://${module.alb["back"].lb_dns_name}" },
      ]
    }
    back = {
      cpu            = 256
      memory         = 512
      min_containers = 1
      max_containers = 3
      container_port = 8000
      environment    = []
    }
  }

  name        = "${var.application_name}-${each.key}"
  cluster_arn = module.app_cluster.arn

  cpu         = each.value.cpu
  memory      = each.value.memory
  launch_type = "FARGATE"
  subnet_ids  = module.vpc.private_subnets

  force_delete = true

  desired_count            = each.value.min_containers
  autoscaling_min_capacity = each.value.min_containers
  autoscaling_max_capacity = each.value.max_containers

  container_definitions = {
    main = {
      name      = "${var.application_name}-${each.key}"
      cpu       = each.value.cpu
      memory    = each.value.memory
      essential = true
      image     = "public.ecr.aws/i5e3i8t5/tutorials-simple-app-${each.key}:latest"
      port_mappings = [
        {
          containerPort = each.value.container_port
          hostPort      = each.value.container_port
          protocol      = "tcp"
        },
      ]
      environment              = each.value.environment
      readonly_root_filesystem = false
    }
  }

  load_balancer = {
    service = {
      target_group_arn = element(module.alb[each.key].target_group_arns, 0)
      container_name   = "${var.application_name}-${each.key}"
      container_port   = each.value.container_port
    }
  }

  security_group_rules = {
    alb_ingress = {
      type                     = "ingress"
      description              = "Allow from LB to service port"
      from_port                = each.value.container_port
      to_port                  = each.value.container_port
      protocol                 = "tcp"
      source_security_group_id = module.alb_security_group.security_group_id
    },
    egress_all = {
      type        = "egress"
      description = "Allow outbound traffic to VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
