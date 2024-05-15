data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "core" {
  filter {
    name   = "tag:Environment"
    values = ["core"]
  }
}

data "aws_vpc" "live" {
  filter {
    name   = "tag:Environment"
    values = ["live"]
  }
}


data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Environment"
    values = [var.environment]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_route53_zone" "primary" {
  name = "${var.region}.${var.environment}.${var.domain}"
}

data "aws_ssm_parameter" "auth_key" {
  name = "/tailscale/key"
}
