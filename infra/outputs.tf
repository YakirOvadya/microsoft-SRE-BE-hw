output "client_id" {
  description = "GitHub Actions Azure SP App ID"
  value       = azuread_service_principal.github_sp.client_id
}

output "client_secret" {
  description = "GitHub Actions Azure SP Secret"
  value       = azuread_service_principal_password.github_sp_password.value
  sensitive   = true
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}