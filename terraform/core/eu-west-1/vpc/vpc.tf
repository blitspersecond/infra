module "vpc" {
  source      = "../../../../modules/vpc"
  vpc_name    = "${data.aws_region.current.id}-${var.environment}-vpc"
  cidr_block  = "10.0.0.0/19"
  fck_nat     = false
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
