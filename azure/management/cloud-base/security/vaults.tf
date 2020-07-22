################################################
################ outputs
################################################

output "azurerm_key_vault_management_id" {
  value = azurerm_key_vault.management.id
}

output "azurerm_key_vault_management_vault_uri" {
  value = azurerm_key_vault.management.vault_uri
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "management" {
  name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, "vault" ] ) 
  resource_group_name         = module.management_common_base_network.data_azurerm_resource_group.name
  location                    = module.management_common_base_network.data_azurerm_resource_group.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true  
  soft_delete_enabled         = true
  purge_protection_enabled    = false
  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    #object_id = data.azurerm_client_config.current.object_id
    object_id = azurerm_user_assigned_identity.mainappgateway.client_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]

    storage_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action = "Allow"
    virtual_network_subnet_ids = [
        module.management_common_base_network.data_azurerm_subnet_dmz.id,
        module.management_common_base_network.data_azurerm_subnet_management.id
    ]
    bypass         = "AzureServices"
  }

  tags = merge(
    module.global_common_base.common_tags
  )
}