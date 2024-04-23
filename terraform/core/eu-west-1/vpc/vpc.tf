data "aws_region" "current" {}

module "hub-vpc" {
  source      = "../../../../modules/vpc"
  vpc_name    = "${data.aws_region.current.id}-hub-vpc"
  cidr_block  = "10.0.0.0/20"
  fck_nat     = false
  environment = "hub"
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

module "live-vpc" {
  source      = "../../../../modules/vpc"
  vpc_name    = "${data.aws_region.current.id}-${var.environment}-vpc"
  cidr_block  = "10.0.16.0/20"
  fck_nat     = true
  environment = "live"
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

### this needs to be commented out on first run
module "live-fk-nat" {
  source         = "../../../../modules/fck-nat"
  vpc_id         = module.live-vpc.vpc_id
  public_subnets = module.live-vpc.public_subnets
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-nat"
    }
  )
  environment = var.environment
}


data "aws_subnets" "vpc_public" {
  filter {
    name   = "vpc-id"
    values = [module.live-vpc.vpc_id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}


### VPC needs to run once with these blocks commented out
# data "aws_subnet" "vpc_public" {
#   for_each   = toset(data.aws_subnets.vpc_public.ids)
#   id         = each.key
#   depends_on = [module.live-vpc]
# }

resource "aws_vpc_peering_connection" "hub-to-eu-west-1-live" {
  peer_vpc_id = module.live-vpc.vpc_id
  vpc_id      = module.hub-vpc.vpc_id
  tags = merge(
    local.tags,
    {
      Name = "${data.aws_region.current.id}-hub-to-${var.environment}"
    }
  )
}

resource "aws_vpc_peering_connection_accepter" "hub-to-eu-west-1-live" {
  vpc_peering_connection_id = aws_vpc_peering_connection.hub-to-eu-west-1-live.id
  auto_accept               = true #
  tags = merge(
    local.tags,
    {
      Name = "${data.aws_region.current.id}-hub-to-${var.environment}"
    }
  )
}

resource "aws_route" "hub-to-eu-west-1-live" {
  route_table_id            = module.hub-vpc.default_route_table_id
  destination_cidr_block    = module.live-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.hub-to-eu-west-1-live.id
}

resource "aws_route" "eu-west-1-live-to-hub" {
  route_table_id            = module.live-vpc.default_route_table_id
  destination_cidr_block    = module.hub-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.hub-to-eu-west-1-live.id
}

# output "az" {
#   value = module.live-fk-nat.public_azs
# }

# # The given "for_each" argument value is unsuitable: the "for_each" argument must be a map, or set of strings, and you have provided a value of type tuple.


# output "local_fixed_az" {
#   value = {
#     for az in module.live-fk-nat.local_vpc_public_azs : index(module.live-fk-nat.local_vpc_public_azs, az) => az
#   }
# }

# module "fck-nat" {

# }

# module "fck-nat" {
#   source = "../../../var/modules/fck-nat"
#   vpc_id = module.live-vpc.vpc_id
#   tags = merge(
#     local.tags,
#     {
#       Name = "${var.environment}-nat"
#     }
#   )
#   environment = var.environment
# }
