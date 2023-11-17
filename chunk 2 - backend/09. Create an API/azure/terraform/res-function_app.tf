resource "azurerm_storage_account" "function-app" {
  name                     = "awsdfsdfasdfsdf"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "this" {
  name                       = "asdfaefadfadf"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.function-app.name
  storage_account_access_key = azurerm_storage_account.function-app.primary_access_key
}