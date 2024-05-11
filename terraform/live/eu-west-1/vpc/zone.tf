module "zone" {
  source      = "../../../../modules/zone"
  tags        = local.tags
  environment = var.environment
  region      = var.region
  domain      = var.domain
}
