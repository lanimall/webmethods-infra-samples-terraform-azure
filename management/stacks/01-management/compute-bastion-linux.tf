################################################
################ Outputs
################################################

output "bastion_linux-public_ip" {
  value = azurerm_public_ip.bastion_linux.*.ip_address
}

output "bastion_linux-public_dns" {
  value = azurerm_public_ip.bastion_linux.*.fqdn
}

output "bastion_linux-private_dns" {
  value = azurerm_network_interface.bastion_linux.*.internal_dns_name_label
}

output "bastion_linux-private_ip" {
  value = azurerm_network_interface.bastion_linux.*.private_ip_address
}

################################################
################ Vars
################################################

variable "instancesize_bastion_linux" {
  description = "instance type for bastion"
}

variable "instancecount_bastion_linux" {
  description = "number of bastion nodes"
}

variable "hostname_bastion_linux" {
  description = "hostname"
}

locals {
  bastion_linux_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  bastion_linux_ip_configuration_name = "ipconfig1"

  bastion_linux_hostnames = azurerm_linux_virtual_machine.bastion_linux.*.computer_name

  bastion_linux_ips = azurerm_network_interface.bastion_linux.*.private_ip_address
  
  bastion_linux_private_dns_fqdns = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_full]), 
    local.bastion_linux_hostnames
  )
}

################################################
################ VM specifics
################################################

# Public IP for Jumpbox
resource "azurerm_public_ip" "bastion_linux" {
  count = var.instancecount_bastion_linux

  name                  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_bastion_linux, "ip", count.index + 1 ] ) 
  resource_group_name   = module.management_common_base_network.data_azurerm_resource_group.name
  location              = module.management_common_base_network.data_azurerm_resource_group.location
  allocation_method     = "Static"
  sku                   = "Basic"

  tags = merge(
    local.bastion_linux_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_bastion_linux, "ip", count.index + 1 ] )
    }
  )
}

resource "azurerm_network_security_group" "bastion_linux" {
  name                    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_bastion_linux, "nsg" ] ) 
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
    destination_port_ranges    = ["22","8090-8091"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  ################ outbound rules
  ################ notes: priority processing stops once a rule matches (and lower umber = processed first)
  security_rule {
    name                       = "SSH-OUT"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22","8090-8091"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(
    local.bastion_linux_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_bastion_linux, "nsg" ] )
    }
  )
}

# Nic for JumpBox Server
resource "azurerm_network_interface" "bastion_linux" {
  count = var.instancecount_bastion_linux
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_bastion_linux, "nic", count.index + 1 ] ) 
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location

  ip_configuration {
    name                          = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.hostname_bastion_linux, "nic", count.index + 1, "ipconfig1" ] ) 
    subnet_id                     = module.management_common_base_network.data_azurerm_subnet_bastion.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_linux[count.index].id
  }

  tags = merge(
    local.bastion_linux_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.hostname_bastion_linux, "nic", count.index + 1 ] )
    }
  )
}

resource "azurerm_network_interface_security_group_association" "bastion_linux" {
  count = var.instancecount_bastion_linux

  network_interface_id      = azurerm_network_interface.bastion_linux[count.index].id
  network_security_group_id = azurerm_network_security_group.bastion_linux.id
}

data "template_file" "setup-bastion-linux" {
  count    = var.instancecount_bastion_linux
  template = file("./resources/setup-bastion-lnx.sh")
}

# JumpBox Server
resource "azurerm_linux_virtual_machine" "bastion_linux" {
  count    = var.instancecount_bastion_linux
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.hostname_bastion_linux, count.index + 1] ) ] ) 
  computer_name             = join("", [ join("", [var.hostname_bastion_linux, count.index + 1 ]) ] )
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  size                      = var.instancesize_bastion_linux
  admin_username                  = var.common_compute_vm_linux.os_admin_user
  disable_password_authentication = true
  custom_data                     = base64encode(data.template_file.setup-bastion-linux[count.index].rendered)

  network_interface_ids = [
    azurerm_network_interface.bastion_linux[count.index].id
  ]

  admin_ssh_key {
    username   = var.common_compute_vm_linux.os_admin_user
    public_key = file(module.management_common_base_security.ssh_bastion_publickey_path)
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
    local.bastion_linux_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, join("", [var.hostname_bastion_linux, count.index + 1] ) ] )
    }
  )
}