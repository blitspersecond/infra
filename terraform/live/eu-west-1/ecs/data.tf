data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "core" {
  filter {
    name   = "tag:Environment"
    values = ["core"]
  }
}

data "aws_vpc" "local" {
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.local.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.local.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

data "aws_route53_zone" "primary" {
  name = "${var.region}.${var.environment}.${var.domain}"
}
