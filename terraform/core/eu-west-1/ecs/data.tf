data "aws_region" "current" {}

data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
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
data "aws_subnets" "spoke_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spoke.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_subnets" "spoke_private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.spoke.id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}
