################################################
################ Outputs
################################################

output "management_windows_private_dns" {
  value = azurerm_network_interface.management_windows.*.internal_dns_name_label
}

output "management_windows_private_ip" {
  value = azurerm_network_interface.management_windows.*.private_ip_address
}

################################################
################ Vars
################################################

variable "instancesize_management_windows" {
  description = "instance type for management"
}

variable "instancecount_management_windows" {
  description = "number of management nodes"
}

variable "hostname_management_windows" {
  description = "hostname"
}

variable "management_windows_admin_password" {
  description = "management windows admin password"
}

locals {
  management_windows_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_windows_tags,
    {}
  )
  
  management_windows_ip_configuration_name = "ipconfig1"

  management_windows_hostnames = azurerm_windows_virtual_machine.management_windows.*.computer_name

  management_windows_ips = azurerm_network_interface.management_windows.*.private_ip_address
  
  management_windows_private_dns_fqdns = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_full]), 
    local.management_windows_hostnames
  )
}

################################################
################ VM specifics
################################################

resource "azurerm_network_security_group" "management_windows" {
  name                    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_management_windows, "nsg" ] ) 
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
    destination_port_ranges    = ["3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  ################ outbound rules
  ################ notes: priority processing stops once a rule matches (and lower umber = processed first)
  security_rule {
    name                       = "ALL-OUT"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = merge(
    local.management_windows_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_management_windows, "nsg" ] )
    }
  )
}

resource "azurerm_network_interface" "management_windows" {
  count = var.instancecount_management_windows
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_management_windows, "nic", count.index + 1 ] ) 
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location

  ip_configuration {
    name                          = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_management_windows, "nic", count.index + 1, "ipconfig1" ] ) 
    subnet_id                     = module.management_common_base_network.data_azurerm_subnet_management.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(
    local.management_windows_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_management_windows, "nic", count.index + 1 ] )
    }
  )
}

resource "azurerm_network_interface_security_group_association" "management_windows" {
  count = var.instancecount_management_windows

  network_interface_id      = azurerm_network_interface.management_windows[count.index].id
  network_security_group_id = azurerm_network_security_group.management_windows.id
}

data "template_file" "setup-management-windows" {
  count    = var.instancecount_management_windows
  template = file("./resources/setup-server.ps1")
}

resource "azurerm_windows_virtual_machine" "management_windows" {
  count    = var.instancecount_management_windows
  
  name                      = join("", [var.hostname_management_windows, count.index + 1] )
  computer_name             = join("", [var.hostname_management_windows, count.index + 1] )
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  size                      = var.instancesize_management_windows
  admin_username                  = var.common_compute_vm_windows.os_admin_user
  admin_password                  = var.management_windows_admin_password
  custom_data                     = base64encode(data.template_file.setup-management-windows[count.index].rendered)

  network_interface_ids = [
    azurerm_network_interface.management_windows[count.index].id
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
    local.management_windows_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, "vm", join("", [var.hostname_management_windows, count.index + 1] ) ] )
    }
  )
}