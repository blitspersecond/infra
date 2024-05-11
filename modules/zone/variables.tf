variable "tags" {
  type = map(string)
  default = {
    Name = "undefined"
  }
}

variable "region" {
  type    = string
  default = "undefined"
}

variable "environment" {
  type    = string
  default = "undefined"
}

variable "domain" {
  type    = string
  default = "undefined"
}

variable "cloudflare_root" {
  type    = bool
  default = false
}
