variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type    = string
  default = "undefined"
}
