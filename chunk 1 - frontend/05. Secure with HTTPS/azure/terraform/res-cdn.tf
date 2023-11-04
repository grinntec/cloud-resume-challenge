# Create an Azure CDN profile
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_profile
resource "azurerm_cdn_profile" "this" {
  name                = "${lower(var.environment)}${lower(random_string.this.result)}-cnd-profile"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard_Microsoft"
}

# Create an Azure CDN endpoint
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_endpoint
resource "azurerm_cdn_endpoint" "this" {
  name                = "${lower(var.environment)}${lower(random_string.this.result)}-cnd-endpoint"
  profile_name        = azurerm_cdn_profile.this.name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  is_http_allowed     = false
  is_https_allowed    = true

  # Extract the domain name from the primary web endpoint and remove the trailing slash
  origin_host_header  = trimsuffix(replace(azurerm_storage_account.this.primary_web_endpoint, "https://", ""), "/")

  origin {
    name      = "storage-account-origin"
    # Extract the domain name from the primary web endpoint and remove the trailing slash
    host_name = trimsuffix(replace(azurerm_storage_account.this.primary_web_endpoint, "https://", ""), "/")
  }

  # Explicitly depend on the storage account to ensure it's fully provisioned
  depends_on = [azurerm_storage_account.this]
}
