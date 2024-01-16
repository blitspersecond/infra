data "aws_region" "current" {}

module "tags" {
  source = "../../../var/modules/tags"
}
