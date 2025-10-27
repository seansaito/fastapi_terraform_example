variable "subscription_id" {
  description = "Azure subscription ID to deploy resources into"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID (used for Key Vault access policies)"
  type        = string
}

variable "location" {
  description = "Azure region short name (e.g., eastus)"
  type        = string
  default     = "japaneast"
}

variable "prefix" {
  description = "Resource name prefix (e.g., azuretodo)"
  type        = string
}

variable "environment" {
  description = "Deployment environment string (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default = {
    project = "azure-todo"
  }
}

variable "container_app_identity_principal_id" {
  description = "Object ID of the managed identity used by the container app. Provide when the identity should have direct Key Vault access."
  type        = string
  default     = null
}

variable "additional_key_vault_access_object_ids" {
  description = "Additional AAD object IDs that require Key Vault secret permissions."
  type        = list(string)
  default     = []
}

variable "container_image" {
  description = "Fully qualified container image for the FastAPI backend (e.g., azuretodoregistry.azurecr.io/todo-api:sha)"
  type        = string
}

variable "acr_name" {
  description = "Existing Azure Container Registry name that hosts backend images"
  type        = string
}

variable "acr_resource_group" {
  description = "Resource group that contains the Azure Container Registry"
  type        = string
}

variable "frontend_artifact_path" {
  description = "Local path to built frontend artifacts if using storage/static website uploads"
  type        = string
  default     = "../frontend/dist"
}

variable "frontend_sku" {
  description = "SKU for Azure Static Web Apps or Storage account if using storage+cdn"
  type        = string
  default     = "Standard"
}

variable "postgres_sku_name" {
  description = "Flexible server SKU name (e.g., B_Standard_B1ms)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "Storage size for Postgres flexible server"
  type        = number
  default     = 32768
}

variable "postgres_admin_login" {
  description = "Admin username for Postgres"
  type        = string
  default     = "psqladmin"
}

variable "postgres_admin_password" {
  description = "Admin password for Postgres"
  type        = string
  sensitive   = true
}

variable "containerapp_min_replicas" {
  description = "Minimum replicas for the backend container app"
  type        = number
  default     = 1
}

variable "containerapp_max_replicas" {
  description = "Maximum replicas for the backend container app"
  type        = number
  default     = 2
}

variable "enable_container_registry" {
  description = "Whether to provision an Azure Container Registry"
  type        = bool
  default     = false
}

variable "custom_domain" {
  description = "Optional custom domain for the frontend (leave blank to skip)"
  type        = string
  default     = ""
}
