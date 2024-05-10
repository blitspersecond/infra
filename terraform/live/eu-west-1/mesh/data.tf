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
