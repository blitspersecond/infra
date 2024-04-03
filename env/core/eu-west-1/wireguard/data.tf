data "aws_region" "current" {}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-*-x86_64"]
  }
}

data "aws_ssoadmin_instances" "ssoadmin_instances" {}
data "aws_caller_identity" "current" {}
data "aws_vpc" "spoke" {
  filter {
    name   = "tag:Name"
    values = ["${data.aws_region.current.id}-${var.environment}-vpc"]
  }
}
data "aws_vpc" "hub" {
  filter {
    name   = "tag:Name"
    values = ["${data.aws_region.current.id}-hub-vpc"]
  }
}
data "aws_subnets" "hub" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spoke.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}
