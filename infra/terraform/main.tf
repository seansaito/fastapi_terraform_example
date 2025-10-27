locals {
  normalized_prefix = lower(replace(var.prefix, "[^a-z0-9]", ""))
  name_suffix       = var.environment
  common_tags       = merge(var.tags, { environment = var.environment })
}

data "azurerm_client_config" "current" {}

data "azurerm_container_registry" "external" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group
}

module "resource_group" {
  source   = "./modules/resource_group"
  name     = "rg-${local.normalized_prefix}-${local.name_suffix}"
  location = var.location
  tags     = local.common_tags
}

module "log_analytics" {
  source              = "./modules/log_analytics"
  name                = "law-${local.normalized_prefix}-${local.name_suffix}"
  location            = var.location
  resource_group_name = module.resource_group.name
  retention_in_days   = 30
  tags                = local.common_tags
}

module "container_registry" {
  source              = "./modules/container_registry"
  count               = var.enable_container_registry ? 1 : 0
  name                = "acr${local.normalized_prefix}${local.name_suffix}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = local.common_tags
}

module "key_vault" {
  source              = "./modules/key_vault"
  name                = "kv-${local.normalized_prefix}-${local.name_suffix}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tenant_id           = var.tenant_id
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "key_vault_secrets_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "time_sleep" "wait_for_key_vault_rbac" {
  depends_on      = [azurerm_role_assignment.key_vault_secrets_officer]
  create_duration = "120s"
}

resource "azurerm_user_assigned_identity" "container_app" {
  name                = "uai-${local.normalized_prefix}-${local.name_suffix}"
  location            = var.location
  resource_group_name = module.resource_group.name
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "container_app_acr" {
  scope                = data.azurerm_container_registry.external.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_app.principal_id
}

module "postgres" {
  source              = "./modules/postgres"
  name                = "psql-${local.normalized_prefix}-${local.name_suffix}"
  resource_group_name = module.resource_group.name
  location            = var.location
  sku_name            = var.postgres_sku_name
  storage_mb          = var.postgres_storage_mb
  admin_login         = var.postgres_admin_login
  admin_password      = var.postgres_admin_password
  tags                = local.common_tags
}

resource "random_password" "jwt" {
  length  = 48
  special = false
}

resource "azurerm_key_vault_secret" "jwt" {
  name         = "jwt-secret"
  value        = random_password.jwt.result
  key_vault_id = module.key_vault.id
  depends_on   = [time_sleep.wait_for_key_vault_rbac]
}

resource "azurerm_key_vault_secret" "database_url" {
  name         = "database-url"
  value        = module.postgres.connection_string
  key_vault_id = module.key_vault.id
  depends_on   = [time_sleep.wait_for_key_vault_rbac]
}

module "static_site" {
  source              = "./modules/static_site"
  name                = "st${local.normalized_prefix}${local.name_suffix}"
  resource_group_name = module.resource_group.name
  location            = var.location
  sku                 = var.frontend_sku
  custom_domain       = var.custom_domain
  tags                = local.common_tags
}

locals {
  frontend_origin       = trimsuffix(module.static_site.endpoint, "/")
  frontend_origin_regex = format("^%s$", replace(trimsuffix(module.static_site.endpoint, "/"), ".", "\\."))
}

module "container_app" {
  source                     = "./modules/container_app"
  name                       = "api-${local.normalized_prefix}-${local.name_suffix}"
  resource_group_name        = module.resource_group.name
  location                   = var.location
  log_analytics_workspace_id = module.log_analytics.id
  container_image            = var.container_image
  min_replicas               = var.containerapp_min_replicas
  max_replicas               = var.containerapp_max_replicas
  registry_server            = data.azurerm_container_registry.external.login_server
  plain_env = {
    APP_ENV           = var.environment
    LOG_LEVEL         = "INFO"
    CORS_ORIGINS      = "http://localhost:5173,${local.frontend_origin}"
    CORS_ORIGIN_REGEX = local.frontend_origin_regex
  }
  secret_env = {
    DATABASE_URL = azurerm_key_vault_secret.database_url.name
    JWT_SECRET   = azurerm_key_vault_secret.jwt.name
  }
  secrets = {
    (azurerm_key_vault_secret.database_url.name) = module.postgres.connection_string
    (azurerm_key_vault_secret.jwt.name)          = random_password.jwt.result
  }
  key_vault_id              = module.key_vault.id
  registry_identity         = azurerm_user_assigned_identity.container_app.id
  user_assigned_identity_id = azurerm_user_assigned_identity.container_app.id
  tags                      = local.common_tags
  depends_on                = [azurerm_role_assignment.container_app_acr]
}
