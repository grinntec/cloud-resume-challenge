azure_subscription_id = "c714dba2-7aff-402d-ab05-7e2d57532a86"
app_name              = "database"
environment           = "dev"
location              = "westeurope"
enable_lock           = false

# Storage Account Variables
account_kind             = "StorageV2"
account_tier             = "Standard"
account_replication_type = "LRS"
access_tier              = "Cool"
create_private_endpoint  = false
vnet_resource_group      = "value"
vnet_name                = "value"
subnet_name              = "value"
create_static_website    = true

# Cosmos DB Account Variables
// Kind
cosmosdb_kind = "GlobalDocumentDB" // (Required) Specifies the Kind of CosmosDB to create. Can be 'GlobalDocumentDB', 'MongoDB', or 'Parse'
// Capacity mode
cosmosdb_capacity_mode     = "provisioned" // The capacity mode for the Cosmos DB account. Can be 'provisioned' or 'serverless'
cosmosdb_enable_serverless = false         // Flag to enable serverless capacity mode. Used only for serverless capacity mode.
cosmosdb_enable_free_tier  = true         // Enable the Free Tier pricing option for this Cosmos DB account.
// Global Distribution
enable_automatic_failover           = false // Enable automatic failover for this Cosmos DB account.
cosmosdb_enable_multi_region_writes = false // Enable multiple write locations for this Cosmos DB account.
cosmosdb_geo_redundancy             = false // Automatically replicates data to the region geo-paired with the current region. Provides 99.999% availability.
secondary_location                  = ""    // The secondary location for failover.
// Consistency
consistency_level       = "Session" // The consistency level of the Cosmos DB account. Can be 'Strong', 'BoundedStaleness', 'Session', 'ConsistentPrefix', or 'Eventual'.
max_interval_in_seconds = "5"       // The maximum lag in seconds for 'BoundedStaleness' consistency level.
max_staleness_prefix    = "100"     // The maximum lag in number of versions (updates) for 'BoundedStaleness' consistency level.
// Networking
network_access_option = "AllNetworks" // The network access option for the Cosmos DB account. Can be 'AllNetworks', 'PublicEndpoint', or 'PrivateEndpoint'.
// Backup
backup_policy_type         = "Periodic" // The type of backup policy for the Cosmos DB account. Can be 'Periodic', 'Continuous7Days', or 'Continuous30Days'.
backup_interval_in_minutes = "240"      // The interval in minutes at which periodic backups are taken (only applicable for 'Periodic' backup policy).
backup_retention_in_hours  = "8"        // The retention period in hours for periodic backups (only applicable for 'Periodic' backup policy).
backup_storage_redundancy  = "Local"    // The type of backup storage redundancy for the Cosmos DB account. Can be 'Local', 'Geo', or 'Zone' (only applicable for 'Periodic' backup policy).

# Cosmos DB SQL Database Variables
cosmosdb_sql_database_name                     = "cloud-resume-challenge"
cosmosdb_sql_database_throughput               = "400" // The throughput of SQL database (RU/s). Must be set in increments of 100. The minimum value is 400.
cosmosdb_sql_database_autoscale_max_throughput = "400" // The maximum throughput of the SQL database (RU/s). Must be between 1,000 and 1,000,000.  

# Cosmos DB SQL Database Container Variables
cosmosdb_sql_container_name               = "Count" // The name of the Cosmos DB SQL container.
cosmosdb_sql_container_partition_key_path = "/id"   // The partition key path for the Cosmos DB SQL container.
cosmosdb_sql_container_throughput         = "400"   // The throughput of the Cosmos DB SQL container (RU/s)