output "id" {
  value = azurerm_log_analytics_workspace.this.id
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.this.workspace_id
}

output "shared_key" {
  value     = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive = true
}
