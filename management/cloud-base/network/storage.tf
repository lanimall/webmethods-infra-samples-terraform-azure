
# generate a random prefix
resource "random_string" "mainstorage" {
  length = 8
  special = false
  upper = false
  number = false
}

# Storage account to hold diag data from VMs and Azure Resources
resource "azurerm_storage_account" "main" {
  name                      = replace(join("", [ module.global_common_base.name_prefix_short, random_string.mainstorage.result ] ) , module.global_common_base.name_delimiter, "")
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"

  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = replace(join("", [ module.global_common_base.name_prefix_long, random_string.mainstorage.result ] ) , module.global_common_base.name_delimiter, "")
    },
  )
}