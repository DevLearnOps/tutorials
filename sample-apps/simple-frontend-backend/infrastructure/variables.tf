########################################################################
#  Generic Variables
########################################################################
variable "environment" {
  description = "The environment name for the infrastructure deployment"
  type        = string
}

variable "tags" {
  description = "(Optional) Additional user defined tags for created resources"
  type        = map(string)
  default     = {}
}

########################################################################
#  Networking Variables
########################################################################
variable "vpc_cidr" {
  description = "(Optional) The Cidr block for the new VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "number_of_azs" {
  description = "(Optional) The number of Availability Zones to create for the VPC"
  type        = number
  default     = 2
  validation {
    condition     = var.number_of_azs >= 1 && var.number_of_azs <= 4
    error_message = "The number_of_azs parameter must be between 1 and 4."
  }
}

########################################################################
#  Application Variables
########################################################################
variable "application_name" {
  description = "The name of the application this infrastructure hosts"
  type        = string
}


