variable "vpc_id" {
  type    = string
  default = "undefined"
}

variable "environment" {
  type    = string
  default = "undefined"
}

variable "tags" {
  type = map(string)
  default = {
    Name = "undefined"
  }
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}
