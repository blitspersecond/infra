data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_ami" "fck_nat" {
  most_recent = true
  owners      = ["568608671756"]
  filter {
    name   = "name"
    values = ["fck-nat-al2023-*-arm64-ebs"]
  }
}

data "aws_subnets" "vpc_public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}
