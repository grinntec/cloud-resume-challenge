############################################################
# RESOURCES
############################################################
# create an azure storage account
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account.html
resource "azurerm_storage_account" "this" {
  name                             = "${lower(random_string.this.result)}${lower(var.environment)}"
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
  public_network_access_enabled    = true
  default_to_oauth_authentication  = false
  is_hns_enabled                   = false
  nfsv3_enabled                    = false

  // configure a static website if set via input variable var.create_static_website
  dynamic "static_website" {
    for_each = var.create_static_website ? [1] : []
    content {
      index_document     = "index.html"
      error_404_document = "error.html" // Optional: Specify a custom error document (e.g., "error.html")
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

  lifecycle {
    ignore_changes = [tags["created_date"]]
  }

  tags = merge(local.common_tags, local.date_tags)
}

############################################################
# VARIABLES
############################################################
variable "account_kind" {
  type        = string
  description = <<-EOT
  (Required) Defines the kind of account.

  Options:
  - BlobStorage
  - BlockBlobStorage
  - FileStorage
  - Storage
  - StorageV2
  EOT

  default = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Invalid account kind. Options are 'BlobStorage', 'BlockBlobStorage', 'FileStorage', 'Storage', or 'StorageV2'."
  }
}

variable "account_tier" {
  type        = string
  description = <<-EOT
  (Required) Defines the performance tier to use for this account.

  Options:
  - Standard
  - Premium
  EOT

  default = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Invalid account tier. Options are 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  type        = string
  description = <<-EOT
  (Required) Defines the type of replication.

  Options:
  - LRS
  - GRS
  - RAGRS
  - ZRS
  - GZRS
  - RAGZRS
  EOT

  default = "GRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Invalid replication type. Options are 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', or 'RAGZRS'."
  }
}

variable "access_tier" {
  type        = string
  description = <<-EOT
  (Required) Defines the access tier to use for this account.

  Options:
  - Hot
  - Cool
  EOT

  default = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Invalid access tier. Options are 'Hot' or 'Cool'."
  }
}

variable "create_private_endpoint" {
  type        = bool
  description = "Create a private endpoint for the storage account."
  default     = false
}

variable "vnet_resource_group" {
  type        = string
  description = "Name of the Vnet resource group"
  default     = ""
}

variable "vnet_name" {
  type        = string
  description = "Name of the Vnet"
  default     = ""
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet"
  default     = ""
}

variable "create_static_website" {
  type        = bool
  description = "Choose to create a static website or not"
  default     = false
}

############################################################
# OUTPUTS
############################################################
output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "primary_web_endpoint" {
  value = azurerm_storage_account.this.primary_web_endpoint
}
