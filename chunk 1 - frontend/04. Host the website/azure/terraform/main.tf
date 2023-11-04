############################################################
# PROVIDER CONFIGURATION
# This block configures the target Azure tenant and subsciption
# and provides the credentials required to manage resources there.
############################################################
# Azure Provider Configuration
provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

/*
The following variables are setup on the client workstation
workstation as environment variables and loaded as part of
the provider setup.

'TF_VAR_client_id' is the service principal client ID
'TF_VAR_client_secret' is the password of the service principal
*/
variable "client_id" {
  description = "Service Principal Client ID"
}

variable "client_secret" {
  description = "Service Principal Client Secret"
  sensitive   = true # This will ensure the value isn't shown in logs or console output
}


/*
DO NOT CHANGE THIS VALUE
It sets the Azure tenant ID which is the same for all Azure subscriptions
*/
variable "azure_tenant_id" {
  description = "Azure Active Directory Tenant ID"
  default     = "17452008-ed27-47bc-b363-3bcb5faa883d" # DO NOT CHANGE THIS VALUE
}

############################################################
# TERRAFORM CONFIGURATION
############################################################
terraform {
  # Backend configuration for remote state in Azure Blob Storage
  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "tfstateaccountsandbox" // Enter the Azure storage account name that hosts the Terraform state; usually as format '{xyzgrvnet}
    container_name       = "tfstatecontainer"
    key                  = "uai1234567-example-dev-resource_group.tfstate" // Format as '{uai}-{app_name}-{environment}-{resource}.tfstate'
    subscription_id      = "c714dba2-7aff-402d-ab05-7e2d57532a86"          // Enter the Azure subscription ID
    tenant_id            = "17452008-ed27-47bc-b363-3bcb5faa883d"          // Enter the Azure tenant ID
  }
}

############################################################
# TERRAFORM CONFIGURATION
############################################################
# This configuration sets the minimum required version for the Terraform binary.
# It ensures that older, potentially incompatible versions aren't used.
# This code requires at least version 1.0 but supports all newer versions.
#
# The Azure provider version should be at least 3.0.
# This allows any minor or patch version above 3.0 but below 4.0.
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

############################################################
# LOCALS
############################################################
locals {
  common_tags = {
    appname = var.app_name
    env     = var.environment
  }

  date_tags = {
    created_date = timestamp()
  }

  common_name = "${var.app_name}-${var.environment}"
}

############################################################
# VARIABLES
############################################################
// These are considered default variables required for most resources in Azure
variable "azure_subscription_id" {
  description = "Azure Subscription ID for the network. It should be in a valid GUID format."
  type        = string

  validation {
    condition     = can(regex("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$", var.azure_subscription_id))
    error_message = "The Azure Subscription ID must be in a valid GUID format (e.g., 12345678-1234-1234-1234-123456789012)."
  }
}

variable "app_name" {
  type        = string
  description = <<EOT
  (Required) Name of the workload. It must start with a letter and end with a letter or number.

  Example:
  - applicationx
  EOT

  validation {
    condition     = length(var.app_name) <= 90 && can(regex("^[a-zA-Z].*[a-zA-Z0-9]$", var.app_name))
    error_message = "app_name is invalid. 'app_name' must be between 1 and 90 characters, start with a letter, and end with a letter or number."
  }
}

variable "environment" {
  type        = string
  description = <<EOT
  (Required) Describe the environment type.

  Options:
  - dev
  - test
  - prod
  EOT

  validation {
    condition     = can(regex("^(dev|test|prod)$", var.environment))
    error_message = "Environment is invalid. Valid options are 'dev', 'test', or 'prod'."
  }
}

variable "location" {
  type        = string
  description = <<EOT
  (Required) Location of where the workload will be managed.

  Options:
  - westeurope
  - eastus
  - southeastasia
  EOT

  validation {
    condition     = can(regex("^(westeurope|eastus|southeastasia)$", var.location))
    error_message = "Location is invalid. Options are 'westeurope', 'eastus', or 'southeastasia'."
  }
}

variable "enable_lock" {
  type        = bool
  description = "Enable or disable a lock on the resource group"
  default     = false
}


// Storage Account Variables
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
  (Required) Defines the access tier to use for this account for BlobStorage, FileStorage, and StorageV2.

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
  description = "Set to true to create a private endpoint for the storage account."
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

