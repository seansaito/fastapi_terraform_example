resource "azurerm_key_vault" "this" {
  name                        = lower(replace(var.name, "_", ""))
  resource_group_name         = var.resource_group_name
  location                    = var.location
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
  enable_rbac_authorization   = false
  public_network_access_enabled = true
  tags                        = var.tags
}
