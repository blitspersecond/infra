# data "aws_ssoadmin_instances" "ssoadmin_instances" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpc" "core" {
  filter {
    name   = "tag:Environment"
    values = ["core"]
  }
}
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
