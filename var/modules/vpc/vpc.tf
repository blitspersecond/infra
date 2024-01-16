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
  for_each          = var.availability_zones
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.key)
  availability_zone = each.value
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${each.value}-public-subnet"
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
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.key + 4)
  availability_zone = each.value
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${each.value}-private-subnet"
    }
  )
}

resource "aws_subnet" "isolated_subnet" {
  for_each          = var.availability_zones
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.key + 8)
  availability_zone = each.value
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${each.value}-isolated-subnet"
    }
  )
}
