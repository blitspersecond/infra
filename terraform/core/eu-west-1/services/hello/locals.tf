locals {
  tags = {
    Environment               = "${var.environment}"
    (module.tags.MANAGED_BY)  = module.tags.TERRAFORM
    (module.tags.ENVIRONMENT) = var.environment
  }
}

variable "environment" {
  type    = string
  default = "undefined"
}
