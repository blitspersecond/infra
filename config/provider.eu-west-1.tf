provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}
