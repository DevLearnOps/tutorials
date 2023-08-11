data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name = "${var.environment}-${var.application_name}"

  azs        = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

