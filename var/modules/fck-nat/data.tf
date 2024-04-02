data "aws_ami" "fck_nat" {
  most_recent = true
  owners      = ["568608671756"]
  filter {
    name   = "name"
    values = ["fck-nat-al2023-hvm-*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
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

data "aws_subnet" "vpc_public" {
  count = length(data.aws_subnets.vpc_public.ids)
  id    = data.aws_subnets.vpc_public.ids[count.index]
}

locals {
  vpc_public_ids = values(zipmap(data.aws_subnet.vpc_public.*.availability_zone, data.aws_subnet.vpc_public.*.id))
}

data "aws_subnets" "vpc_private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnet" "vpc_private" {
  count = length(data.aws_subnets.vpc_private.ids)
  id    = data.aws_subnets.vpc_private.ids[count.index]
}

locals {
  vpc_private_ids = values(zipmap(data.aws_subnet.vpc_private.*.availability_zone, data.aws_subnet.vpc_private.*.id))
}
