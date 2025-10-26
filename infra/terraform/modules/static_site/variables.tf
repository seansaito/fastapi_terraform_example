variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
  default = "Standard"
}

variable "custom_domain" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
