data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_route_tables" "vpc" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_vpc" "peer" {
  id = var.vpc_peer_id
}

data "aws_route_tables" "peer" {
  vpc_id = var.vpc_peer_id
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}
