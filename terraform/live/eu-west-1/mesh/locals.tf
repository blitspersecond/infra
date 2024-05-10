locals {
  tags = {
    Stack                     = "${var.stack}"
    Environment               = "${var.environment}"
    (module.tags.MANAGED_BY)  = module.tags.TERRAFORM
    (module.tags.ENVIRONMENT) = var.environment
  }
}

