variable "container_name" {
  description = "The name of the application container"
  type        = string
}

variable "exposed_port" {
  description = "The local port number to map for the application"
  type        = number
}

variable "restart_policy" {
  description = "(Optional) The container restart policy"
  type        = string
  default     = "no"
}
