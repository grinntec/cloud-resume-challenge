# create an azure storage account
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account.html
resource "azurerm_storage_account" "this" {
  name                             = "${lower(var.environment)}${lower(random_string.this.result)}"
  resource_group_name              = azurerm_resource_group.this.name
  location                         = var.location
  account_kind                     = var.account_kind
  account_tier                     = var.account_tier
  account_replication_type         = var.account_replication_type
  cross_tenant_replication_enabled = true
  access_tier                      = var.access_tier
  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  shared_access_key_enabled        = true
  public_network_access_enabled    = false
  default_to_oauth_authentication  = false
  is_hns_enabled                   = false
  nfsv3_enabled                    = false

  dynamic "static_website" {
    for_each = var.create_static_website ? [1] : []
    content {
      index_document     = "index.html"
      error_404_document = "error.html"
    }
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  blob_properties {
    container_delete_retention_policy {
      days = 7
    }
    delete_retention_policy {
      days = 7
    }
    change_feed_retention_in_days = null
    default_service_version       = "2020-04-08"
    last_access_time_enabled      = true
    versioning_enabled            = true
  }

  tags = merge(local.common_tags, local.date_tags)
  lifecycle {
    ignore_changes = [tags["created_date"]]
  }
}
