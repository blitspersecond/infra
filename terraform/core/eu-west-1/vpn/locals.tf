locals {
  tags = {
    Environment               = "${var.environment}"
    (module.tags.MANAGED_BY)  = module.tags.TERRAFORM
    (module.tags.ENVIRONMENT) = var.environment
  }
  host-types = [
    "t4g.nano", # $0.0104 per hour
  ]
}
