# Create a random value for the resource
// https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "this" {
  length  = 6 # Adjust as needed
  special = false
  upper   = true
  numeric = true
  lower   = true
}
