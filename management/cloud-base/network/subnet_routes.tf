################################################
################ outputs
################################################


################################################
################ subnets - bastion
################################################

resource "azurerm_route" "dmz_internal" {
  name                = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_dmz, "internal" ] )
  resource_group_name = azurerm_resource_group.main.name
  route_table_name    = azurerm_route_table.internal.name
  address_prefix      = azurerm_subnet.dmz.address_prefix
  next_hop_type       = "vnetlocal"
}

resource "azurerm_route" "bastion_internal" {
  name                = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.subnet_shortname_bastion, "internal" ] )
  resource_group_name = azurerm_resource_group.main.name
  route_table_name    = azurerm_route_table.internal.name
  address_prefix      = azurerm_subnet.bastion.address_prefix
  next_hop_type       = "vnetlocal"
}

################################################
################ subnets - management
################################################

resource "azurerm_route" "management_internal" {
  name                = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.subnet_shortname_management, "internal" ] )
  resource_group_name = azurerm_resource_group.main.name
  route_table_name    = azurerm_route_table.internal.name
  address_prefix      = azurerm_subnet.management.address_prefix
  next_hop_type       = "vnetlocal"
}