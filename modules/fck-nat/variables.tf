variable "vpc_id" {
  type    = string
  default = "undefined"
}

variable "tags" {
  type = map(string)
  default = {
    Name = "undefined"
  }
}

variable "environment" {
  type    = string
  default = "undefined"
}

variable "public_subnets" {
  type    = list(string)
}
