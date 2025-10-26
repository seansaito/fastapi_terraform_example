resource "azurerm_postgresql_flexible_server" "this" {
  name                   = lower(replace(var.name, "_", ""))
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  administrator_login    = var.admin_login
  administrator_password = var.admin_password
  version                = "16"
  zone                   = "1"
  maintenance_window {
    day_of_week  = 0
    start_hour   = 0
    start_minute = 0
  }
  authentication {
    password_auth_enabled = true
  }
  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
