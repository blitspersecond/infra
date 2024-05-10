variable "tags" {
  type = map(string)
  default = {
    Name = "undefined"
  }
}
variable "vpc_id" {
  type    = string
  default = false
}

variable "vpc_peer_id" {
  type    = string
  default = false
}

variable "environment" {
  type    = string
  default = "undefined"
}
