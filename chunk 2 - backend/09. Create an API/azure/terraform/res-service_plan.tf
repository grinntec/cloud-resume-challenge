# Create an Azure Service Plan
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
resource "azurerm_service_plan" "this" {
  name                   = "${lower(var.environment)}${lower(random_string.this.result)}-app-service-plan"
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  os_type                = var.service_plan_os_type
  sku_name               = var.service_plan_sku
  zone_balancing_enabled = var.service_plan_zone_balancing

  tags = merge(local.common_tags, local.date_tags)
  lifecycle {
    ignore_changes = [tags["created_date"]]
  }
}

############################################################
# VARIABLES
############################################################
variable "service_plan_os_type" {
  type        = string
  description = <<-EOT
  (Required) The O/S type for the App Services to be hosted in this plan. 
  
  Options:
  - Windows
  - Linux
  - WindowsContainer. Changing this forces a new resource to be created.  
  EOT
}

variable "service_plan_sku" {
  type        = string
  description = <<-EOT
  (Required) The SKU for the plan.
  
  Options:
  Consumtion (Serverless)
    - Y1

  Premium Plan
    - EP1, EP2, EP3

  App Service Plan (Dedicated)
    - B1, B2, B3 (Basic)
    - S1, S2, S3 (Standard)
    - P1v2, P2v2, P3v2 (Premium V2)
    - P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3 (Premium V3)
    - I1, I2, I3, I1v2, I2v2, I3v2, I4v2, I5v2, I6v2 (Isolated)
  EOT
}

variable "service_plan_zone_balancing" {
  type        = bool
  description = "Should the Service Plan balance across Availability Zones in the region. Changing this forces a new resource to be created."
}