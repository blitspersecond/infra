locals {
  tags = {
    (module.tags.MANAGED_BY)  = module.tags.TERRAFORM
    (module.tags.ENVIRONMENT) = var.environment
  }
}

