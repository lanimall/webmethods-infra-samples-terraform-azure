
output "data_azurerm_resource_group" {
  value = data.azurerm_resource_group.main
}

output "data_azurerm_virtual_network" {
  value = data.azurerm_virtual_network.main
}

output "data_azurerm_subnet_dmz" {
  value = data.azurerm_subnet.dmz
}

output "data_azurerm_subnet_management" {
  value = data.azurerm_subnet.management
}

output "data_azurerm_subnet_bastion" {
  value = data.azurerm_subnet.bastion
}

output "base_dns_internal_domain_full" {
  value = data.terraform_remote_state.base_network.outputs.dns_internal_domain_full
}

output "base_dns_internal_domain_top" {
  value = data.terraform_remote_state.base_network.outputs.dns_internal_domain_top
}

output "base_dns_internal_domain_sub" {
  value = data.terraform_remote_state.base_network.outputs.dns_internal_domain_sub
}