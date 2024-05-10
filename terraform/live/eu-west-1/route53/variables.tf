variable "domain" {
  type        = string
  default     = ""
  description = "domain name"
}

variable "environment" {
  type        = string
  default     = ""
  description = "environment name"
}

variable "region" {
  type    = string
  default = "undefined"
}

variable "stack" {
  type    = string
  default = "undefined"
}
