data "aws_region" "current" {}

module "hub-vpc" {
  source     = "../../../var/modules/vpc"
  vpc_name   = "${data.aws_region.current.id}-hub-vpc"
  cidr_block = "10.0.0.0/20"
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

module "production-vpc" {
  source     = "../../../var/modules/vpc"
  vpc_name   = "${data.aws_region.current.id}-${var.environment}-vpc"
  cidr_block = "10.0.16.0/20"
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

resource "aws_vpc_peering_connection" "hub-to-eu-west-1-production" {
  peer_vpc_id = module.production-vpc.vpc_id
  vpc_id      = module.hub-vpc.vpc_id
  tags = merge(
    local.tags,
    {
      Name = "${data.aws_region.current.id}-hub-to-${var.environment}"
    }
  )
}

resource "aws_vpc_peering_connection_accepter" "hub-to-eu-west-1-production" {
  vpc_peering_connection_id = aws_vpc_peering_connection.hub-to-eu-west-1-production.id
  auto_accept               = true
}

resource "aws_route" "hub-to-eu-west-1-production" {
  route_table_id            = module.hub-vpc.default_route_table_id
  destination_cidr_block    = module.production-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.hub-to-eu-west-1-production.id
}

resource "aws_route" "eu-west-1-production-to-hub" {
  route_table_id            = module.production-vpc.default_route_table_id
  destination_cidr_block    = module.hub-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.hub-to-eu-west-1-production.id
}
