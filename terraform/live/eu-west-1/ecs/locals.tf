locals {
  tags = {
    Stack                     = "${var.stack}"
    Environment               = "${var.environment}"
    (module.tags.MANAGED_BY)  = module.tags.TERRAFORM
    (module.tags.ENVIRONMENT) = var.environment
  }
  host-types = [
    "t3.micro", # $0.0104 per hour
    "t2.micro", # $0.0136 per hour
  ]
}
