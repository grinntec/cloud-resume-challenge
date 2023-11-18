############################################################
# RESOURCES
############################################################
# Create a custom DNS record in Azure DNS
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record
resource "azurerm_dns_cname_record" "this" {
  name                = var.dns_cname_record
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group
  ttl                 = 3600
  target_resource_id  = azurerm_cdn_endpoint.this.id

  lifecycle {
    ignore_changes = [tags["created_date"]]
  }

  tags = merge(local.common_tags, local.date_tags)
}

############################################################
# VARIABLES
############################################################
variable "dns_cname_record" {
  type        = string
  description = "(Required) The name of the DNS CNAME Record."
}

variable "dns_zone_name" {
  type        = string
  description = "(Required) Specifies the DNS Zone where the resource exists"
}

variable "dns_zone_resource_group" {
  type        = string
  description = "(Required) Specifies the resource group where the DNS Zone (parent resource) exists"
}