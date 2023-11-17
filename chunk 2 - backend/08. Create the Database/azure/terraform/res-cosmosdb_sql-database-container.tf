# Create an Azure CosmosDB SQL Container
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container
resource "azurerm_cosmosdb_sql_container" "this" {
  name                = var.cosmosdb_sql_container_name
  resource_group_name = azurerm_resource_group.this.name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name

  partition_key_path = var.cosmosdb_sql_container_partition_key_path
  throughput         = var.cosmosdb_sql_container_throughput
}

############################################################
# VARIABLES
############################################################
variable "cosmosdb_sql_container_name" {
  description = "The name of the Cosmos DB SQL container."
  type        = string
}

variable "cosmosdb_sql_container_partition_key_path" {
  description = "The partition key path for the Cosmos DB SQL container."
  type        = string
}

variable "cosmosdb_sql_container_throughput" {
  description = "The throughput of the Cosmos DB SQL container (RU/s)."
  type        = number
}
