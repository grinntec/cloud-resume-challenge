############################################################
# RESOURCES
############################################################
# Create a resource group
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "this" {
  name     = "${local.common_name}-rg"
  location = var.location

  lifecycle {
    ignore_changes = [tags["created_date"]]
  }

  tags = merge(local.common_tags, local.date_tags)
}

# Create a resource group lock
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock
resource "azurerm_management_lock" "this" {
  count      = var.enable_lock ? 1 : 0
  name       = "${azurerm_resource_group.this.name}-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Locking the resource group to prevent accidental deletion to all the resources within"
}

############################################################
# VARIABLES
############################################################
variable "enable_lock" {
  type        = bool
  description = "Enable or disable a lock on the resource group"
  default     = false
}

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