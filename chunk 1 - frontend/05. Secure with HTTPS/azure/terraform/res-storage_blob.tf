############################################################
# LOCALS
############################################################
locals {
  files = fileset(var.content_directory, "**/*")
}

############################################################
# DATA
############################################################
data "local_file" "file" {
  for_each = { for f in local.files : f => f }
  filename = "${var.content_directory}/${each.value}"
}

############################################################
# RESOURCE
############################################################
# Create storage account blobs
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob

resource "azurerm_storage_blob" "files" {
  for_each = data.local_file.file

  name                   = each.key
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = trimsuffix(each.key, ".css") == each.key ? "text/html" : "text/css"

  source      = each.value.filename
  content_md5 = filemd5(each.value.filename)
}

############################################################
# VARIABLES
############################################################
variable "content_directory" {
  type        = string
  description = "The path to the directory with the website content"
}