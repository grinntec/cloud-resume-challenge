############################################################
# TERRAFORM CONFIGURATION
############################################################
# This configuration sets the minimum required version for the Terraform binary.
# It ensures that older, potentially incompatible versions aren't used.
# This code requires at least version 1.0 but supports all newer versions up to
# the very latest release.
#
# The AzureRM provider version should be at least 3.0.
# This allows any minor or patch version above 3.0 but below 4.0.
#
# The random provider version should be at least 3.0.
# This allows any minor or patch version above 3.0 but below 4.0.
#
# To support Terraform state a backend configuration is set that is specific
# to this deployment. The target subscription is based on separate environmental
# settings on the runner. The storag accont, container, and key (name of the state
# file) are hard coded.

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-state"
    storage_account_name = "tfstategrinntec"
    container_name       = "tfstatecontainer"
    key                  = "cloud-resume-challenge.tfstate"
  }
}

############################################################
# PROVIDER CONFIGURATION
############################################################
# This block configures the target Azure tenant and subsciption
# and provides the credentials required to manage resources there.

# Azure Provider Configuration
provider "azurerm" {
  use_oidc = true
  features {}
}

# Hashicorp random provider
provider "random" {
  # Configuration options
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
