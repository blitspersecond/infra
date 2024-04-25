module "vpc" {
  source      = "../../../../modules/vpc"
  vpc_name    = "${data.aws_region.current.id}-${var.environment}-vpc"
  cidr_block  = "10.0.32.0/19"
  fck_nat     = true
  environment = var.environment
  availability_zones = {
    0 = "${data.aws_region.current.id}a"
    1 = "${data.aws_region.current.id}b"
    2 = "${data.aws_region.current.id}c"
  }
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}

module "peering" {
  source      = "../../../../modules/peering"
  vpc_id      = module.vpc.vpc_id
  vpc_peer_id = data.aws_vpc.core.id
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-vpc-peering"
    }
  )
  depends_on = [module.vpc]
}

