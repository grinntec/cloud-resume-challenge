############################################################
# OUTPUTS
############################################################
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "The location of the resource"
  value       = azurerm_resource_group.this.location
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "primary_web_endpoint" {
  value = azurerm_storage_account.this.primary_web_endpoint
}
