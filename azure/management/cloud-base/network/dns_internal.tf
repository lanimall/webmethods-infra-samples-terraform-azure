output "dns_internal_domain_full" {
  value = azurerm_private_dns_zone.main_internal.name
}

output "dns_internal_domain_top" {
  value = var.dns_internal_topdomain
}

output "dns_internal_domain_sub" {
  value = var.dns_internal_subdomain
}


resource "azurerm_private_dns_zone" "main_internal" {
  name                = join(".", [ var.dns_internal_subdomain, var.dns_internal_topdomain ] )
  resource_group_name = azurerm_resource_group.main.name

  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-Main Internal DNS"
    },
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "main_internal" {
  name                  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join(module.global_common_base.name_delimiter, [ "internal", "dns" ] ) ] )
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.main_internal.name
  virtual_network_id    = azurerm_virtual_network.main.id
}