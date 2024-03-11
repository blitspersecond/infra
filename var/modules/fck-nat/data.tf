data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_ami" "fck_nat" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-*-arm64"]
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
