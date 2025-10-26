output "endpoint" {
  value = azurerm_storage_account.this.primary_web_endpoint
}

output "name" {
  value = azurerm_storage_account.this.name
}
