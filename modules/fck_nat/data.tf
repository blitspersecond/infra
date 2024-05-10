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

data "aws_subnet" "public" {
  id = var.public_subnet_id
}

data "aws_subnet" "private" {
  id = var.private_subnet_id
}

data "aws_route_table" "private" {
  subnet_id = data.aws_subnet.private.id
}

# data "aws_subnets" "vpc_public" {
#   filter {
#     name   = "vpc-id"
#     values = [var.vpc_id]
#   }
#   filter {
#     name   = "tag:Type"
#     values = ["public"]
#   }
# }

# data "aws_subnet" "vpc_public" {
#   for_each = var.public_subnets.ids
#   id       = each.key
# }

# locals {
#   public_subnets = {
#     for az in data.aws_subnet.vpc_public : az.availability_zone => az.id
#   }
# }

# output "public_subnet_ids" {
#   value = var.public_subnets
# }

# data "availability_zone" "availability_zone" {
#   # get az from subnet
# }


# data "aws_subnets" "vpc_private" {
#   filter {
#     name   = "vpc-id"
#     values = [var.vpc_id]
#   }
#   filter {
#     name   = "tag:Type"
#     values = ["private"]
#   }
# }

# data "aws_subnet" "vpc_private" {
#   count = length(data.aws_subnets.vpc_private.ids)
#   id    = data.aws_subnets.vpc_private.ids[count.index]
# }

# locals {
#   vpc_private_azs = keys(zipmap(data.aws_subnet.vpc_private.*.availability_zone, data.aws_subnet.vpc_private.*.id))
#   vpc_private_ids = values(zipmap(data.aws_subnet.vpc_private.*.availability_zone, data.aws_subnet.vpc_private.*.id))
#   azs = {
#     for az in local.vpc_public_ids : index(local.vpc_public_ids, az) => az
#   }
# }

# output "local_fixed_az" {
#   value = {
#     for az in module.live-fk-nat.local_vpc_public_azs : index(module.live-fk-nat.local_vpc_public_azs, az) => az
#   }
# }
