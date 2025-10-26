variable "name" {
  type        = string
  description = "Log Analytics workspace name"
}

variable "location" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "retention_in_days" {
  type        = number
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
