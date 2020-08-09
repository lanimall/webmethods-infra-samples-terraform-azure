################################################
################ Outputs
################################################

output "commandcentral_hostnames" {
  value = local.commandcentral_hostnames
}

# output "commandcentral_private_dns_fqdns" {
#   value = local.commandcentral_private_dns_fqdns
# }

# output "commandcentral_private_dns_short" {
#   value = local.commandcentral_private_dns_short
# }

output "commandcentral_ips" {
  value = local.commandcentral_ips
}


################################################
################ Vars
################################################

variable "commandcentral_instancesize" {
  description = "instance type for management"
}

variable "commandcentral_instancecount" {
  description = "number of cce nodes"
}

variable "commandcentral_hostname" {
  description = "hostname"
}

variable "commandcentral_osdisk_storage_account_type" {
  description = "os disk type"
}

variable "commandcentral_datadisk_storage_account_type" {
  description = "app/data disk type"
}

variable "commandcentral_datadisk_size_gb" {
  description = "app/data disk size (in gb)"
}

################################################
################ Locals
################################################

locals {
  commandcentral_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )

  commandcentral_ip_configuration_name = "ipconfig1"

  commandcentral_hostnames = azurerm_linux_virtual_machine.commandcentral.*.computer_name

  commandcentral_ips = azurerm_network_interface.commandcentral.*.private_ip_address
  
  commandcentral_private_dns_short = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_sub]), 
    local.commandcentral_hostnames
  )

  commandcentral_private_dns_fqdns = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_full]), 
    local.commandcentral_hostnames
  )
}

################################################
################ DNS specifics
################################################

resource "azurerm_private_dns_a_record" "commandcentral" {
  count = var.commandcentral_instancecount

  name                = join(module.global_common_base.hostname_delimiter, [var.commandcentral_hostname, count.index + 1 ])
  zone_name           = module.management_common_base_network.base_dns_internal_domain_full
  resource_group_name = module.management_common_base_network.data_azurerm_resource_group.name
  ttl                 = 300
  records             = [
    azurerm_network_interface.commandcentral[count.index].private_ip_address
  ]
}

################################################
################ VM specifics
################################################

resource "azurerm_network_security_group" "commandcentral" {
  name                    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.commandcentral_hostname, "nsg" ] ) 
  resource_group_name   = module.management_common_base_network.data_azurerm_resource_group.name
  location              = module.management_common_base_network.data_azurerm_resource_group.location

  ################ outbound rules
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

  security_rule {
    name                       = "CCE-IN"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8090-8093"]
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
    destination_port_ranges    = ["22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "CCE-OUT"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range    = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(
    local.commandcentral_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.commandcentral_hostname, "nsg" ] )
    }
  )
}

resource "azurerm_network_interface" "commandcentral" {
  count = var.commandcentral_instancecount
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.commandcentral_hostname, "nic", count.index + 1 ] ) 
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  #internal_dns_name_label   = join(".", [ join(module.global_common_base.hostname_delimiter, [var.commandcentral_hostname, count.index + 1 ]), module.management_common_base_network.base_dns_internal_domain_sub])

  ip_configuration {
    name                          = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.commandcentral_hostname, "nic", count.index + 1, local.commandcentral_ip_configuration_name ] ) 
    subnet_id                     = module.management_common_base_network.data_azurerm_subnet_management.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(
    local.commandcentral_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.commandcentral_hostname, "nic", count.index + 1 ] )
    }
  )
}

resource "azurerm_network_interface_security_group_association" "commandcentral" {
  count = var.commandcentral_instancecount

  network_interface_id      = azurerm_network_interface.commandcentral[count.index].id
  network_security_group_id = azurerm_network_security_group.commandcentral.id
}

data "template_file" "setup-management-linux" {
  count    = var.commandcentral_instancecount
  template = file("./resources/setup-server.sh")
}

resource "azurerm_managed_disk" "commandcentral" {
  count    = var.commandcentral_instancecount
  
  name                 = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.commandcentral_hostname, count.index + 1] ), "disk1" ] ) 
  resource_group_name  = module.management_common_base_network.data_azurerm_resource_group.name
  location             = module.management_common_base_network.data_azurerm_resource_group.location
  storage_account_type = var.commandcentral_datadisk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.commandcentral_datadisk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "commandcentral" {
  count    = var.commandcentral_instancecount
  
  managed_disk_id    = azurerm_managed_disk.commandcentral[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.commandcentral[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_linux_virtual_machine" "commandcentral" {
  count    = var.commandcentral_instancecount
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.commandcentral_hostname, count.index + 1] ) ] ) 
  computer_name             = join("", [ join("", [var.commandcentral_hostname, count.index + 1 ]) ] )
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  size                      = var.commandcentral_instancesize
  admin_username                  = var.common_compute_vm_linux.os_admin_user
  disable_password_authentication = true
  custom_data                     = base64encode(data.template_file.setup-management-linux[count.index].rendered)

  network_interface_ids = [
    azurerm_network_interface.commandcentral[count.index].id
  ]

  admin_ssh_key {
    username   = var.common_compute_vm_linux.os_admin_user
    public_key = file(module.management_common_base_security.ssh_bastion_publickey_path)
  }

  os_disk {
    name                 = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.commandcentral_hostname, count.index + 1] ) , "osdisk" ] )
    storage_account_type = var.commandcentral_osdisk_storage_account_type
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = var.common_compute_vm_linux.os_image.publisher
    offer     = var.common_compute_vm_linux.os_image.offer
    sku       = var.common_compute_vm_linux.os_image.sku
    version   = var.common_compute_vm_linux.os_image.version
  }
  
  tags = merge(
    local.commandcentral_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, join("", [var.commandcentral_hostname, count.index + 1] ) ] )
    }
  )
}

################################################
################ Load Balancer
################################################

## protected management external load balancer
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "commandcentral_managementexternal" {
  count    = var.commandcentral_instancecount
  
  ip_configuration_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.commandcentral_hostname, "nic", count.index + 1, local.commandcentral_ip_configuration_name ] )
  network_interface_id    = azurerm_network_interface.commandcentral[count.index].id
  backend_address_pool_id = module.management_common_base_loadbalancing.appgateway_backend_address_pool_id_commandcentral
}