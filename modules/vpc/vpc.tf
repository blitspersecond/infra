#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs TODO: flow logs are expensive and not required for all VPCs
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-internet-gateway"
    }
  )
}
resource "aws_subnet" "public_subnet" {
  for_each                = var.availability_zones
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 5, each.key)
  availability_zone       = each.value
  map_public_ip_on_launch = false
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${each.value}-public-subnet"
      Type = "public"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  for_each = var.availability_zones
  vpc_id   = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${each.value}-public-route-table"
    }
  )
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_route_table[each.key].id
}

resource "aws_subnet" "private_subnet" {
  for_each          = var.availability_zones
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 5, each.key + 8)
  availability_zone = each.value
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${each.value}-private-subnet"
      Type = "private"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  for_each = var.availability_zones
  vpc_id   = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${each.value}-private-route-table"
    }
  )
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_route_table[each.key].id
}



resource "aws_subnet" "isolated_subnet" {
  for_each          = var.availability_zones
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 5, each.key + 16)
  availability_zone = each.value
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${each.value}-isolated-subnet"
      Type = "isolated"
    }
  )
}

module "fck_nat" {
  for_each          = var.fck_nat ? var.availability_zones : {}
  source            = "../fck_nat"
  public_subnet_id  = aws_subnet.public_subnet[each.key].id
  private_subnet_id = aws_subnet.private_subnet[each.key].id
  environment       = var.environment
  vpc_id            = aws_vpc.vpc.id
  tags              = var.tags
}
