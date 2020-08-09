################################################
################ Outputs
################################################

output "network_resource_group_main_name" {
  value = azurerm_resource_group.main.name
}

output "network_resource_group_main_id" {
  value = azurerm_resource_group.main.id
}

output "network_main_id" {
  value = azurerm_virtual_network.main.id
}

output "network_main_name" {
  value = azurerm_virtual_network.main.name
}

output "network_main_address_space" {
  value = azurerm_virtual_network.main.address_space
}

################################################
################ Local vars
################################################

locals {
  main_cidr = join(
    ".",
    [
      var.network_cidr_prefix,
      var.network_cidr_suffix
    ]
  )
}

################################################
################ resource group
################################################

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = module.global_common_base.name_friendly_id
  location = var.cloud_region

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags
  )
}

################################################
################ main network address
################################################

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "main" {
  name                = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, "net" ] )
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = [ local.main_cidr ]

  //  Use our common tags and add a specific name.
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, "net" ] )
    },
  )
}

################################################
################ Internal Private routes
################################################

resource "azurerm_route_table" "internal" {
  name                          = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, "internal" ] )
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  disable_bgp_route_propagation = false
  
  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, "internal" ] )
    }
  )
}