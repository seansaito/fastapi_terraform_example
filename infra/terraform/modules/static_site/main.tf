resource "random_string" "suffix" {
  length  = 4
  lower   = true
  upper   = false
  special = false
  numeric = true
}

locals {
  base_name = substr(lower(replace(var.name, "[^a-z0-9]", "")), 0, 18)
}

resource "azurerm_storage_account" "this" {
  name                     = format("%s%s", local.base_name, random_string.suffix.result)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = true
  tags                     = var.tags
  static_website {
    index_document     = "index.html"
    error_404_document = "index.html"
  }
}
