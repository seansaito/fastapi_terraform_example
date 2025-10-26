output "resource_group_name" {
  value       = module.resource_group.name
  description = "Name of the resource group"
}

output "container_app_fqdn" {
  value       = module.container_app.fqdn
  description = "Public FQDN for the FastAPI backend"
}

output "frontend_endpoint" {
  value       = module.static_site.endpoint
  description = "URL for the frontend application"
}

output "postgres_fqdn" {
  value       = module.postgres.fqdn
  description = "Postgres flexible server hostname"
}

output "key_vault_name" {
  value       = module.key_vault.name
  description = "Name of the Key Vault storing secrets"
}
