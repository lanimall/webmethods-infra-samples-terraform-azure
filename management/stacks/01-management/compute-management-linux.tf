################################################
################ Outputs
################################################

output "management_linux-private_dns" {
  value = azurerm_network_interface.management_linux.*.internal_dns_name_label
}

output "management_linux-private_ip" {
  value = azurerm_network_interface.management_linux.*.private_ip_address
}

################################################
################ Vars
################################################

variable "instancesize_management_linux" {
  description = "instance type for management"
}

variable "instancecount_management_linux" {
  description = "number of management nodes"
}

variable "hostname_management_linux" {
  description = "hostname"
}

locals {
  management_linux_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )
    
  management_linux_ip_configuration_name = "ipconfig1"

  management_linux_hostnames = azurerm_linux_virtual_machine.management_linux.*.computer_name

  management_linux_ips = azurerm_network_interface.management_linux.*.private_ip_address
  
  management_linux_private_dns_fqdns = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_full]), 
    local.management_linux_hostnames
  )
}

################################################
################ VM specifics
################################################

resource "azurerm_network_security_group" "management_linux" {
  name                    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_management_linux, "nsg" ] ) 
  resource_group_name   = module.management_common_base_network.data_azurerm_resource_group.name
  location              = module.management_common_base_network.data_azurerm_resource_group.location

  ################ inbound rules
  ################ notes: priority processing stops once a rule matches (and lower umber = processed first)
  security_rule {
    name                       = "SSH-IN"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
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
    local.management_linux_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_management_linux, "nsg" ] )
    }
  )
}

resource "azurerm_network_interface" "management_linux" {
  count = var.instancecount_management_linux
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_management_linux, "nic", count.index + 1 ] ) 
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location

  ip_configuration {
    name                          = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_management_linux, "nic", count.index + 1, "ipconfig1" ] ) 
    subnet_id                     = module.management_common_base_network.data_azurerm_subnet_management.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(
    local.management_linux_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_management_linux, "nic", count.index + 1 ] )
    }
  )
}

resource "azurerm_network_interface_security_group_association" "management_linux" {
  count = var.instancecount_management_linux

  network_interface_id      = azurerm_network_interface.management_linux[count.index].id
  network_security_group_id = azurerm_network_security_group.management_linux.id
}

data "template_file" "setup-management-linux" {
  count    = var.instancecount_management_linux
  template = file("./resources/setup-server.sh")
}

# JumpBox Server
resource "azurerm_linux_virtual_machine" "management_linux" {
  count    = var.instancecount_management_linux
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.hostname_management_linux, count.index + 1] ) ] ) 
  computer_name             = join("", [ join("", [var.hostname_management_linux, count.index + 1 ]) ] )
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  size                      = var.instancesize_management_linux
  admin_username                  = var.common_compute_vm_linux.os_admin_user
  disable_password_authentication = true
  custom_data                     = base64encode(data.template_file.setup-management-linux[count.index].rendered)

  network_interface_ids = [
    azurerm_network_interface.management_linux[count.index].id
  ]

  admin_ssh_key {
    username   = var.common_compute_vm_linux.os_admin_user
    public_key = file(module.management_common_base_security.ssh_internal_publickey_path)
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = var.common_compute_vm_linux.os_image.publisher
    offer     = var.common_compute_vm_linux.os_image.offer
    sku       = var.common_compute_vm_linux.os_image.sku
    version   = var.common_compute_vm_linux.os_image.version
  }
  
  tags = merge(
    local.management_linux_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, join("", [var.hostname_management_linux, count.index + 1] ) ] )
    }
  )
}