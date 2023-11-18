############################################################
# DATA
############################################################
data "azurerm_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group
}

############################################################
# RESOURCES
############################################################
# Create an Azure CDN profile
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_profile
resource "azurerm_cdn_profile" "this" {
  name                = "${lower(random_string.this.result)}-${lower(var.environment)}-cdn-profile"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard_Microsoft"

  lifecycle {
    ignore_changes = [tags["created_date"]]
  }

  tags = merge(local.common_tags, local.date_tags)
}

# Create an Azure CDN endpoint
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_endpoint
resource "azurerm_cdn_endpoint" "this" {
  name                = "${lower(random_string.this.result)}-${lower(var.environment)}-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.this.name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  is_http_allowed     = false
  is_https_allowed    = true

  # Extract the domain name from the primary web endpoint and remove the trailing slash
  origin_host_header = trimsuffix(replace(azurerm_storage_account.this.primary_web_endpoint, "https://", ""), "/")

  origin {
    name = "storage-account-origin"
    # Extract the domain name from the primary web endpoint and remove the trailing slash
    host_name = trimsuffix(replace(azurerm_storage_account.this.primary_web_endpoint, "https://", ""), "/")
  }

  // forces any http traffic to re-route to https
  delivery_rule {
    name  = "EnforceHTTPS"
    order = "1"

    request_scheme_condition {
      operator     = "Equal"
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
  }

  # Explicitly depend on the storage account to ensure it's fully provisioned
  depends_on = [azurerm_storage_account.this]

  lifecycle {
    ignore_changes = [tags["created_date"]]
  }

  tags = merge(local.common_tags, local.date_tags)
}
