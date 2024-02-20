provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}
