variable "name" {
  type        = string
  description = "Registry name"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "admin_enabled" {
  type    = bool
  default = false
}
