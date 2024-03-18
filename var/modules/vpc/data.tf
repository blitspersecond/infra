# data "aws_ami" "fck_nat" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-2023*-kernel-*-arm64"]
#   }
# }

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
    values = [aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}
