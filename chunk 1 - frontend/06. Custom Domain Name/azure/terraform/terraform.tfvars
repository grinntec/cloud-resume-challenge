# Universal
app_name    = "cloudresumechallenge" // (Required) Must be between 1 and 90 characters, start with a letter, and end with a letter or number.
environment = "dev"                  // (Required) Describe the environment type. Options are 'dev', 'test', or 'prod'.
location    = "westeurope"           // (Required) Location of where the workload will be managed. Options are 'westeurope', 'eastus', or 'southeastasia'

# Resource Group
enable_lock = false // (Required) Enable or disable a lock on the resource group. Options are 'true' or 'false'.

# Storage Account
account_kind             = "StorageV2"  // (Required) Defines the kind of account. Options are 'BlobStorage', 'BlockBlobStorage', 'FileStorage', 'Storage', or 'StorageV2'.
account_tier             = "Standard"   // (Required) Defines the performance tier to use for this account. Options are 'Standard' or 'Premium'.
account_replication_type = "LRS"        // (Required) Defines the type of replication. Options are 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', or 'RAGZRS'.
access_tier              = "Cool"       // (Required) Defines the access tier to use for this account. Options are 'Hot' or 'Cool'.
create_private_endpoint  = false        // (Required) Create a private endpoint for the storage account. Options are 'true' or 'false'
vnet_resource_group      = ""           // (Optional) If creating a private endpoint. Name of the VNet resource group.
vnet_name                = ""           // (Optional) If creating a private endpoint. Name of the VNet.
subnet_name              = ""           // (Optional) If creating a private endpoint. Name of the subnet where the endpoint will be set.
create_static_website    = true         // (Required) Enable static website hosting on the storage account. Options are 'true' or 'false'
content_directory        = "../website" // (Optional) If using a static website. The path to the directory with the website content.