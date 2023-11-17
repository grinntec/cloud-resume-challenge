resource "azurerm_resource_group" "this" {
  name     = "${local.common_name}-rg"
  location = var.location
  tags     = merge(local.common_tags, local.date_tags)
  lifecycle {
    ignore_changes = [tags["created_date"]]
  }
}

resource "azurerm_management_lock" "this" {
  count      = var.enable_lock ? 1 : 0
  name       = "${azurerm_resource_group.this.name}-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Locking the resource group to prevent accidental deletion to all the resources within"
}
