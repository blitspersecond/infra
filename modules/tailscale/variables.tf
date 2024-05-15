variable "auth_key" {
  description = "Arn of the Tailscale auth key in SSM Parameter Store"
  type        = string
}

variable "environment" {
  description = "The environment to deploy the Tailscale VPN into"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy the Tailscale VPN into"
  type        = string
}

variable "tags" {
  type = map(string)
  default = {
    Name = "undefined"
  }
}

variable "subnet_ids" {
  type = list(string)
}

variable "cidr_blocks" {
  type = string
}
