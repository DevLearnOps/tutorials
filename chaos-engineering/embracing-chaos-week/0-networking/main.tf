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

data "aws_availability_zones" "available" {}

locals {
  name     = "embracing-chaos"
  vpc_cidr = "10.0.0.0/16"
  num_azs  = 2
  azs      = slice(data.aws_availability_zones.available.names, 0, local.num_azs)
}

#############################################################
# Create the VPC                                            #
#############################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  single_nat_gateway = true
  enable_nat_gateway = true
}

#############################################################
# Save VPC information in SSM parameters                    #
#############################################################
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/vpc/id"
  value = module.vpc.vpc_id
  type  = "String"
}
resource "aws_ssm_parameter" "public_subnets" {
  name  = "/vpc/public_subnets"
  value = join(",", module.vpc.public_subnets)
  type  = "StringList"
}
resource "aws_ssm_parameter" "private_subnets" {
  name  = "/vpc/private_subnets"
  value = join(",", module.vpc.private_subnets)
  type  = "StringList"
}
