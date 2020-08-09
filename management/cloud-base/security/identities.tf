################################################
################ outputs
################################################

output "azurerm_user_assigned_identity_mainappgateway_name" {
  value = azurerm_user_assigned_identity.mainappgateway.name
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_user_assigned_identity" "mainappgateway" {
  name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, "mainappgateway" ] )
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  
  tags = merge(
    module.global_common_base.common_tags
  )
}

resource "azurerm_role_assignment" "mainappgateway_keyvault" {
  scope                = data.azurerm_subscription.primary.id
  principal_id         = azurerm_user_assigned_identity.mainappgateway.principal_id
  role_definition_name = "Key Vault Contributor"
}