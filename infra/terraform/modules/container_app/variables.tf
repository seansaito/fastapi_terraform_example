variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "container_image" {
  type = string
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 2
}

variable "plain_env" {
  type    = map(string)
  default = {}
}

variable "secret_env" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type        = map(string)
  description = "Map of secret_name => secret_value"
  default     = {}
}

variable "key_vault_id" {
  type = string
}

variable "key_vault_identity" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "target_port" {
  type    = number
  default = 8000
}

variable "registry_server" {
  type    = string
  default = ""
}

variable "registry_username" {
  type    = string
  default = ""
}

variable "registry_password_secret_name" {
  type    = string
  default = ""
}

variable "registry_identity" {
  type    = string
  default = null
}

variable "user_assigned_identity_id" {
  type    = string
  default = null
}
