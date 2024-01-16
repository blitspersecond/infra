

variable "vpc_name" {
  type    = string
  default = "undefined"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/20"
}

variable "tags" {
  type = map(string)
  default = {
    Name = "undefined"
  }
}

variable "availability_zones" {
  type = map(string)
}
