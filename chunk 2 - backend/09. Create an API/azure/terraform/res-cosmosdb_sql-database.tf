/*
# Throughput
Throughput in Azure Cosmos DB is the performance capacity of the database, measured in Request Units per 
second (RU/s). It's provisioned for containers or databases. Adjusting the variable value changes the 
throughput.

# Autoscale
Autoscale in Azure Cosmos DB automatically adjusts the throughput (RU/s) of your database or container 
based on the workload. It's ideal for workloads with variable traffic patterns, ensuring performance 
while optimizing costs.

*/
# Create an Azure CosmosDB SQL Database
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database

# Create an Azure CosmosDB SQL Database
resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.cosmosdb_sql_database_name
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name

  # Conditionally set throughput or autoscale settings
  throughput = var.cosmosdb_sql_database_use_autoscale ? null : var.cosmosdb_sql_database_throughput

  dynamic "autoscale_settings" {
    for_each = var.cosmosdb_sql_database_use_autoscale ? [1] : []
    content {
      max_throughput = var.cosmosdb_sql_database_autoscale_max_throughput
    }
  }
}

############################################################
# VARIABLES
############################################################
variable "cosmosdb_sql_database_name" {
  type = string
}

variable "cosmosdb_sql_database_use_autoscale" {
  description = "Set to true to use autoscale settings, false to use fixed throughput."
  type        = bool
  default     = false
}

variable "cosmosdb_sql_database_throughput" {
  description = <<EOT
  (Optional) The throughput of SQL database (RU/s). Must be set in increments of 100. The minimum value is 400.
  
  - This must be set upon database creation otherwise it cannot be updated without a manual terraform destroy-apply.
  - Do not set when azurerm_cosmosdb_account is configured with EnableServerless capability.
  EOT

  type    = number
  default = 400 # Set a default value or adjust as needed
}

variable "cosmosdb_sql_database_autoscale_max_throughput" {
  description = <<EOT
  (Optional) The maximum throughput of the SQL database (RU/s). Must be between 1,000 and 1,000,000.
  
  - Must be set in increments of 1,000. 
  - Conflicts with throughput
  EOT

  type    = number
  default = 4000 # Set your desired default maximum autoscale throughput here
}
