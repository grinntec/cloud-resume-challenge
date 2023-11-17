/*
# Kind
In Azure Cosmos DB, the "kind" property determines the API type for the account:

GlobalDocumentDB: Default, for SQL (Core) API.
MongoDB: For MongoDB API compatibility.
Cassandra: For Cassandra API compatibility.

# Capacity Mode
In Azure Cosmos DB, there are two capacity modes you can choose from: provisioned throughput and serverless.
- Provisioned throughput offers predictable performance with manual scaling
- Serverless is an autoscaling option with a pay-per-request model

# Free tier mode
The Azure Cosmos DB free tier option is designed to provide a cost-effective solution for small-scale or development scenarios.
When you apply the free tier discount to an Azure Cosmos DB account, you receive the first 400 RU/s (Request Units per second) 
and 5 GB of storage for free each month. This can be particularly beneficial for trying out Cosmos DB features, developing and
testing applications, or running small workloads without incurring costs.

# Global Distribution
Geo-redundancy in Azure Cosmos DB refers to the automatic replication of data across multiple geographic regions. This ensures
that if one region experiences an outage or failure, your data remains available and accessible from other regions, providing
high availability and disaster recovery for your applications.

Multi-region writes in Azure Cosmos DB allow you to replicate your data across multiple geographic regions and enable clients to
write to the nearest region. This feature enhances the availability and responsiveness of your database by allowing read and write
operations in multiple regions, rather than restricting writes to a single primary region. In the event of a regional outage, another
region can seamlessly take over the write operations, ensuring continuous availability of your application.

# Consistency
Azure Cosmos DB offers five levels of consistency to choose from, providing a spectrum between strong and eventual consistency. These
levels allow you to make trade-offs between consistency, availability, and latency. Here's a brief overview of each:

- Strong Consistency: Guarantees that reads always return the most recent committed version of an item. Provides linearizability.
- Bounded Staleness: Guarantees that reads are not too out-of-date by specifying a prefix consistency window in terms of time or number of operations (updates).
- Session Consistency: Guarantees monotonic reads, monotonic writes, read-your-writes, and write-follows-reads guarantees for a session.
- Consistent Prefix: Guarantees that reads never see out-of-order writes. If writes are performed in a specific sequence, they are seen in the same sequence.
- Eventual Consistency: Provides the weakest consistency level but the lowest latency. Reads might not always reflect the latest writes.

# Networking
The "All Networks" option in Azure Cosmos DB configuration essentially means that the Cosmos DB account is accessible from any IP
address over the internet. There are no restrictions on the IP addresses that can connect to the database, making it the most open
and least restrictive access option. This setting is typically used for development or testing environments where ease of access is
prioritized over security. However, for production environments, it's recommended to use more restrictive settings to ensure the
security of your data.

The "Public Endpoint" option in Azure Cosmos DB allows the database to be accessed over the public internet, but with specific 
restrictions in place. Unlike the "All Networks" option, which allows unrestricted access, the "Public Endpoint" option enables you
to define a set of allowed IP addresses or CIDR blocks. Only requests originating from these specified IP ranges will be granted access
to the Cosmos DB account. This option provides a balance between accessibility and security, allowing public internet access while still
restricting it to known, trusted sources.

The "Private Endpoint" option in Azure Cosmos DB enables you to access your database over a private network connection. This means that
the Cosmos DB account is not accessible over the public internet. Instead, it's accessed through a private link from within an Azure Virtual
Network (VNet). This setup provides enhanced security and isolation, as the database can only be reached from specified private networks,
reducing exposure to potential threats on the public internet. It's a preferred option for production environments where security and privacy
are paramount.

# Backup policy
# Cosmos DB Backup Policies:
 Periodic: Scheduled backups (default every 4 hours). Configurable interval and retention.
 Continuous: Real-time backups with point-in-time recovery up to 30 days.

# Backup Storage Redundancy Options:
 LRS: Local redundancy within a single region.
 GRS: Geo-redundancy with replication to a secondary region.
 ZRS: Zone redundancy across multiple availability zones.

# Cosmos DB Encryption:
# - Data at rest is encrypted by default using service-managed keys.
# - Option to use customer-managed keys (CMK) for additional control.
# - All data in transit is encrypted using TLS/SSL.



*/


# Create a Cosmos DB Account
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account
resource "azurerm_cosmosdb_account" "this" {
  name                = "${lower(var.environment)}${lower(random_string.this.result)}-cosmosdb-account"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  # Kind
  kind = var.cosmosdb_kind

  # Capacity mode
  offer_type = var.cosmosdb_capacity_mode == "provisioned" ? var.cosmosdb_offer_type : null

  dynamic "capabilities" {
    for_each = var.cosmosdb_capacity_mode == "serverless" ? [1] : []
    content {
      name = "EnableServerless"
    }
  }

  # Free tier mode
  enable_free_tier = var.cosmosdb_enable_free_tier

  # Global Distribution
  enable_automatic_failover       = false
  enable_multiple_write_locations = var.cosmosdb_enable_multi_region_writes

  // Conditional geo-redundancy configuration
  // Primary geo-location (always present)
  geo_location {
    location          = azurerm_resource_group.this.location
    failover_priority = 0
  }

  // Secondary geo-location (optional)
  dynamic "geo_location" {
    for_each = var.cosmosdb_geo_redundancy ? [1] : []
    content {
      location          = var.secondary_location
      failover_priority = 1
    }
  }

  # Consistency
  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.consistency_level == "BoundedStaleness" ? var.max_interval_in_seconds : null
    max_staleness_prefix    = var.consistency_level == "BoundedStaleness" ? var.max_staleness_prefix : null
  }

  # Networking
  // Enable public network access when the PublicEndpoint option is selected
  #public_network_access_enabled = var.network_access_option == "PublicEndpoint"
  public_network_access_enabled = var.network_access_option == "AllNetworks" || var.network_access_option == "PublicEndpoint"



  # Conditionally set IP range filter based on the network access option
  ip_range_filter = var.network_access_option == "AllNetworks" ? "" : var.network_access_option == "PublicEndpoint" ? join(",", var.allowed_ip_ranges) : null

  # Backup policy
  dynamic "backup" {
    for_each = var.backup_policy_type == "Periodic" ? [1] : []
    content {
      type                = "Periodic"
      interval_in_minutes = var.backup_interval_in_minutes
      retention_in_hours  = var.backup_retention_in_hours
      storage_redundancy  = var.backup_storage_redundancy
    }
  }

  dynamic "backup" {
    for_each = var.backup_policy_type == "Continuous7Days" ? [1] : []
    content {
      type               = "Continuous"
      retention_in_hours = 168 # 7 days
    }
  }

  dynamic "backup" {
    for_each = var.backup_policy_type == "Continuous30Days" ? [1] : []
    content {
      type               = "Continuous"
      retention_in_hours = 720 # 30 days
    }
  }
}

############################################################
# VARIABLES
############################################################
# Kind
variable "cosmosdb_kind" {
  type        = string
  description = <<-EOT
    (Required) Specifies the Kind of CosmosDB to create
    
    Options:
     - GlobalDocumentDB
     - MongoDB
     - Parse
    EOT
}

# Capacity mode
variable "cosmosdb_capacity_mode" {
  description = "The capacity mode for the Cosmos DB account. Can be 'provisioned' or 'serverless'."
  type        = string
  default     = "provisioned"

  validation {
    condition     = contains(["provisioned", "serverless"], var.cosmosdb_capacity_mode)
    error_message = "The capacity mode must be either 'provisioned' or 'serverless'."
  }
}

// Used to specify the offer type for provisioned throughput mode.
variable "cosmosdb_offer_type" {
  description = "The offer type for the Cosmos DB account. Used only for provisioned capacity mode."
  type        = string
  default     = "Standard"

  validation {
    condition     = var.cosmosdb_offer_type == "Standard"
    error_message = "The offer type must be 'Standard'."
  }
}

// Enable serverless capacity mode
variable "cosmosdb_enable_serverless" {
  description = "Flag to enable serverless capacity mode. Used only for serverless capacity mode."
  type        = bool
  default     = false

  validation {
    condition     = var.cosmosdb_enable_serverless == false
    error_message = "The enable_serverless flag must be false."
  }
}

// Enable free tier mode
variable "cosmosdb_enable_free_tier" {
  description = "(Optional) Enable the Free Tier pricing option for this Cosmos DB account."
  type        = bool

  validation {
    condition     = var.cosmosdb_enable_free_tier == false || var.cosmosdb_enable_free_tier == true
    error_message = "The enable_free_tier flag must be either true or false."
  }
}

# Global Distribution
variable "enable_automatic_failover" {
  description = "Enable automatic failover for this Cosmos DB account."
  type        = bool
  default     = true
}

variable "cosmosdb_enable_multi_region_writes" {
  description = "(Optional) Enable multiple write locations for this Cosmos DB account."
  type        = bool
  default     = false

  validation {
    condition     = var.cosmosdb_enable_multi_region_writes == false || var.cosmosdb_enable_multi_region_writes == true
    error_message = "The cosmosdb_enable_multi_region_writes flag must be either true or false."
  }
}

variable "cosmosdb_geo_redundancy" {
  description = "value"
  type        = bool
  default     = false

  validation {
    condition     = var.cosmosdb_geo_redundancy == false || var.cosmosdb_geo_redundancy == true
    error_message = "The cosmosdb_geo_redundancy flag must be either true or false."
  }
}

variable "secondary_location" {
  description = "The secondary location for failover."
  type        = string
  default     = "East US"
}



// Consistency
variable "consistency_level" {
  description = "The consistency level of the Cosmos DB account. Can be 'Strong', 'BoundedStaleness', 'Session', 'ConsistentPrefix', or 'Eventual'."
  type        = string
  default     = "Session"
}

variable "max_interval_in_seconds" {
  description = "The maximum lag in seconds for 'BoundedStaleness' consistency level."
  type        = number
  default     = 5
}

variable "max_staleness_prefix" {
  description = "The maximum lag in number of versions (updates) for 'BoundedStaleness' consistency level."
  type        = number
  default     = 100
}


// Networking
variable "network_access_option" {
  description = "The network access option for the Cosmos DB account. Can be 'AllNetworks', 'PublicEndpoint', or 'PrivateEndpoint'."
  type        = string
  default     = "AllNetworks"
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges that are allowed to access the Cosmos DB account when using the PublicEndpoint option."
  type        = list(string)
  default     = []
}

// Backup
variable "backup_policy_type" {
  description = "(Required) The type of backup policy for the Cosmos DB account. Can be 'Periodic', 'Continuous7Days', or 'Continuous30Days'."
  type        = string
  default     = "Periodic"
}

variable "backup_interval_in_minutes" {
  description = "The interval in minutes at which periodic backups are taken (only applicable for 'Periodic' backup policy)."
  type        = number
  default     = 240 # Default is 240 minutes (4 hours)
}

variable "backup_retention_in_hours" {
  description = "The retention period in hours for periodic backups (only applicable for 'Periodic' backup policy)."
  type        = number
  default     = 8 # Default is 8 hours
}

variable "backup_storage_redundancy" {
  description = "The type of backup storage redundancy for the Cosmos DB account. Can be 'Local', 'Geo', or 'Zone'."
  type        = string
  default     = "Geo" # Default to Geo-Redundant Storage
}



############################
//
variable "cosmosdb_max_throughput" {
  description = "The maximum throughput limit for the Cosmos DB account (in RU/s)."
  type        = number
  default     = 4000 # Set your desired default maximum throughput limit here

  validation {
    condition     = var.cosmosdb_max_throughput >= 400 && var.cosmosdb_max_throughput <= 1000000
    error_message = "The maximum throughput must be between 400 RU/s and 1,000,000 RU/s."
  }
}

//








