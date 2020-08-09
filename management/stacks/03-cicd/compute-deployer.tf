################################################
################ Outputs
################################################

output "deployer_hostnames" {
  value = local.deployer_hostnames
}

output "deployer_private_dns_fqdns" {
  value = local.deployer_private_dns_fqdns
}

output "deployer_private_dns_short" {
  value = local.deployer_private_dns_short
}

output "deployer_ips" {
  value = local.deployer_ips
}


################################################
################ Vars
################################################

variable "deployer_instancesize" {
  description = "instance type for management"
}

variable "deployer_instancecount" {
  description = "number of cce nodes"
}

variable "deployer_hostname" {
  description = "hostname"
}

variable "deployer_osdisk_storage_account_type" {
  description = "os disk type"
}

variable "deployer_datadisk_storage_account_type" {
  description = "app/data disk type"
}

variable "deployer_datadisk_size_gb" {
  description = "app/data disk size (in gb)"
}

################################################
################ Locals
################################################

locals {
  deployer_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )
  
  deployer_ip_configuration_name = "ipconfig1"

  deployer_hostnames = azurerm_linux_virtual_machine.deployer.*.computer_name

  deployer_ips = azurerm_network_interface.deployer.*.private_ip_address
  
  deployer_private_dns_short = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_sub]), 
    local.deployer_hostnames
  )

  deployer_private_dns_fqdns = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_full]), 
    local.deployer_hostnames
  )
}

################################################
################ DNS specifics
################################################

resource "azurerm_private_dns_a_record" "deployer" {
  count = var.deployer_instancecount

  name                = join(module.global_common_base.hostname_delimiter, [var.deployer_hostname, count.index + 1 ])
  zone_name           = module.management_common_base_network.base_dns_internal_domain_full
  resource_group_name = module.management_common_base_network.data_azurerm_resource_group.name
  ttl                 = 300
  records             = [
    azurerm_network_interface.deployer[count.index].private_ip_address
  ]
}

################################################
################ VM specifics
################################################

resource "azurerm_network_security_group" "deployer" {
  name                    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.deployer_hostname, "nsg" ] ) 
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
    local.deployer_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.deployer_hostname, "nsg" ] )
    }
  )
}

resource "azurerm_network_interface" "deployer" {
  count = var.deployer_instancecount
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.deployer_hostname, "nic", count.index + 1 ] ) 
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  #internal_dns_name_label   = join(".", [ join(module.global_common_base.hostname_delimiter, [var.deployer_hostname, count.index + 1 ]), module.management_common_base_network.base_dns_internal_domain_sub])

  ip_configuration {
    name                          = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.deployer_hostname, "nic", count.index + 1, local.deployer_ip_configuration_name ] ) 
    subnet_id                     = module.management_common_base_network.data_azurerm_subnet_management.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(
    local.deployer_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.deployer_hostname, "nic", count.index + 1 ] )
    }
  )
}

resource "azurerm_network_interface_security_group_association" "deployer" {
  count = var.deployer_instancecount

  network_interface_id      = azurerm_network_interface.deployer[count.index].id
  network_security_group_id = azurerm_network_security_group.deployer.id
}

data "template_file" "setup-deployer" {
  count    = var.deployer_instancecount
  template = file("./resources/setup-server.sh")
}

resource "azurerm_managed_disk" "deployer" {
  count    = var.deployer_instancecount
  
  name                 = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.deployer_hostname, count.index + 1] ), "disk1" ] ) 
  resource_group_name  = module.management_common_base_network.data_azurerm_resource_group.name
  location             = module.management_common_base_network.data_azurerm_resource_group.location
  storage_account_type = var.deployer_datadisk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.deployer_datadisk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "deployer" {
  count    = var.deployer_instancecount
  
  managed_disk_id    = azurerm_managed_disk.deployer[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.deployer[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_linux_virtual_machine" "deployer" {
  count    = var.deployer_instancecount
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.deployer_hostname, count.index + 1] ) ] ) 
  computer_name             = join("", [ join("", [var.deployer_hostname, count.index + 1 ]) ] )
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  size                      = var.deployer_instancesize
  admin_username                  = var.common_compute_vm_linux.os_admin_user
  disable_password_authentication = true
  custom_data                     = base64encode(data.template_file.setup-deployer[count.index].rendered)

  network_interface_ids = [
    azurerm_network_interface.deployer[count.index].id
  ]

  admin_ssh_key {
    username   = var.common_compute_vm_linux.os_admin_user
    public_key = file(module.management_common_base_security.ssh_bastion_publickey_path)
  }

  os_disk {
    name                 = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.deployer_hostname, count.index + 1] ) , "osdisk" ] )
    storage_account_type = var.deployer_osdisk_storage_account_type
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = var.common_compute_vm_linux.os_image.publisher
    offer     = var.common_compute_vm_linux.os_image.offer
    sku       = var.common_compute_vm_linux.os_image.sku
    version   = var.common_compute_vm_linux.os_image.version
  }
  
  tags = merge(
    local.deployer_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, join("", [var.deployer_hostname, count.index + 1] ) ] )
    }
  )
}

################################################
################ Load Balancer
################################################

## protected management external load balancer
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "deployer_managementexternal" {
  count    = var.deployer_instancecount
  
  ip_configuration_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.deployer_hostname, "nic", count.index + 1, local.deployer_ip_configuration_name ] )
  network_interface_id    = azurerm_network_interface.deployer[count.index].id
  backend_address_pool_id = module.management_common_base_loadbalancing.appgateway_backend_address_pool_id_deployer
}