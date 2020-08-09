################################################
################ Outputs
################################################

output "bastion_windows_public_ip" {
  value = azurerm_public_ip.bastion_windows.*.ip_address
}

output "bastion_windows_public_dns" {
  value = azurerm_public_ip.bastion_windows.*.fqdn
}

output "bastion_windows_private_dns" {
  value = azurerm_network_interface.bastion_windows.*.internal_dns_name_label
}

output "bastion_windows_private_ip" {
  value = azurerm_network_interface.bastion_windows.*.private_ip_address
}

################################################
################ Vars
################################################

variable "instancesize_bastion_windows" {
  description = "instance type for bastion"
}

variable "instancecount_bastion_windows" {
  description = "number of bastion nodes"
}

variable "hostname_bastion_windows" {
  description = "hostname"
}

variable "bastion_windows_admin_password" {
  description = "bastion windows admin password"
}

locals {
  bastion_windows_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_windows_tags,
    {}
  )
    
  bastion_windows_ip_configuration_name = "ipconfig1"

  bastion_windows_hostnames = azurerm_windows_virtual_machine.bastion_windows.*.computer_name

  bastion_windows_ips = azurerm_network_interface.bastion_windows.*.private_ip_address
  
  bastion_windows_private_dns_fqdns = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_full]), 
    local.bastion_windows_hostnames
  )
}

################################################
################ VM specifics
################################################

# Public IP for Jumpbox
resource "azurerm_public_ip" "bastion_windows" {
  count = var.instancecount_bastion_windows

  name                  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_bastion_windows, "ip", count.index + 1 ] ) 
  resource_group_name   = module.management_common_base_network.data_azurerm_resource_group.name
  location              = module.management_common_base_network.data_azurerm_resource_group.location
  allocation_method     = "Static"
  sku                   = "Basic"

  tags = merge(
    local.bastion_windows_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_bastion_windows, "ip", count.index + 1 ] )
    }
  )
}

# NSG for JumpBox Server
resource "azurerm_network_security_group" "bastion_windows" {
  name                    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_bastion_windows, "nsg" ] ) 
  resource_group_name   = module.management_common_base_network.data_azurerm_resource_group.name
  location              = module.management_common_base_network.data_azurerm_resource_group.location

  ################ inbound rules  
  ################ notes: priority processing stops once a rule matches (and lower umber = processed first)
  security_rule {
    name                       = "RDP-TCP-IN"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3389","443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP-UDP-IN"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_ranges    = ["3391"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  ################ outbound rules
  ################ notes: priority processing stops once a rule matches (and lower umber = processed first)
  security_rule {
    name                       = "RDP-OUT"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(
    local.bastion_windows_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_bastion_windows, "nsg" ] )
    }
  )
}

# Nic for JumpBox Server
resource "azurerm_network_interface" "bastion_windows" {
  count = var.instancecount_bastion_windows
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_bastion_windows, "nic", count.index + 1 ] ) 
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location

  ip_configuration {
    name                          = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_bastion_windows, "nic", count.index + 1, "ipconfig1" ] ) 
    subnet_id                     = module.management_common_base_network.data_azurerm_subnet_bastion.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_windows[count.index].id
  }

  tags = merge(
    local.bastion_windows_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_bastion_windows, "nic", count.index + 1 ] )
    }
  )
}

resource "azurerm_network_interface_security_group_association" "bastion_windows" {
  count = var.instancecount_bastion_windows

  network_interface_id      = azurerm_network_interface.bastion_windows[count.index].id
  network_security_group_id = azurerm_network_security_group.bastion_windows.id
}

data "template_file" "setup-bastion-windows" {
  count    = var.instancecount_bastion_windows
  template = file("./resources/setup-server.ps1")
}

# JumpBox Server
resource "azurerm_windows_virtual_machine" "bastion_windows" {
  count    = var.instancecount_bastion_windows
  
  name                      = join("", [var.hostname_bastion_windows, count.index + 1] )
  computer_name             = join("", [var.hostname_bastion_windows, count.index + 1] )
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  size                      = var.instancesize_bastion_windows
  admin_username                  = var.common_compute_vm_windows.os_admin_user
  admin_password                  = var.bastion_windows_admin_password
  custom_data                     = base64encode(data.template_file.setup-bastion-windows[count.index].rendered)

  network_interface_ids = [
    azurerm_network_interface.bastion_windows[count.index].id
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = var.common_compute_vm_windows.os_image.publisher
    offer     = var.common_compute_vm_windows.os_image.offer
    sku       = var.common_compute_vm_windows.os_image.sku
    version   = var.common_compute_vm_windows.os_image.version
  }
  
  tags = merge(
    local.bastion_windows_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, "vm", join("", [var.hostname_bastion_windows, count.index + 1] ) ] )
    }
  )
}