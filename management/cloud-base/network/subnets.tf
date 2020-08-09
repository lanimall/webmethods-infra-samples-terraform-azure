################################################
################ outputs
################################################

output "network_subnet_dmz_name" {
  value = azurerm_subnet.dmz.name
}

output "network_subnet_dmz_id" {
  value = azurerm_subnet.dmz.id
}

output "network_subnet_management_name" {
  value = azurerm_subnet.management.name
}

output "network_subnet_management_id" {
  value = azurerm_subnet.management.id
}

output "network_subnet_bastion_name" {
  value = azurerm_subnet.bastion.name
}

output "network_subnet_bastion_id" {
  value = azurerm_subnet.bastion.id
}

################################################
################ subnets - dmz
################################################

resource "azurerm_subnet" "dmz" {
  name                 = join( module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.subnet_shortname_dmz, "subnet" ] )
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix = cidrsubnet(
    format(
      "%s.%s",
      var.network_cidr_prefix,
      var.subnet_allocation_map_suffixes[var.subnet_shortname_dmz_size],
    ),
    var.subnet_allocation_newbit_size[var.subnet_shortname_dmz_size],
    var.subnet_shortname_dmz_index
  )

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
}

################################################
################ subnets - bastion
################################################

resource "azurerm_subnet" "bastion" {
  name                 = join( module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.subnet_shortname_bastion, "subnet" ] )
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix = cidrsubnet(
    format(
      "%s.%s",
      var.network_cidr_prefix,
      var.subnet_allocation_map_suffixes[var.subnet_shortname_bastion_size],
    ),
    var.subnet_allocation_newbit_size[var.subnet_shortname_bastion_size],
    var.subnet_shortname_bastion_index
  )
}

################################################
################ subnets - management
################################################

resource "azurerm_subnet" "management" {
  name                 = join( module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.subnet_shortname_management, "subnet" ] )
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix = cidrsubnet(
    format(
      "%s.%s",
      var.network_cidr_prefix,
      var.subnet_allocation_map_suffixes[var.subnet_shortname_management_size],
    ),
    var.subnet_allocation_newbit_size[var.subnet_shortname_management_size],
    var.subnet_shortname_management_index
  )

  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
}