################################################
################ Outputs
################################################

output "jenkins_hostnames" {
  value = local.jenkins_hostnames
}

output "jenkins_private_dns_fqdns" {
  value = local.jenkins_private_dns_fqdns
}

output "jenkins_private_dns_short" {
  value = local.jenkins_private_dns_short
}

output "jenkins_ips" {
  value = local.jenkins_ips
}


################################################
################ Vars
################################################

variable "jenkins_instancesize" {
  description = "instance type for management"
}

variable "jenkins_instancecount" {
  description = "number of cce nodes"
}

variable "jenkins_hostname" {
  description = "hostname"
}

variable "jenkins_osdisk_storage_account_type" {
  description = "os disk type"
}

variable "jenkins_datadisk_storage_account_type" {
  description = "app/data disk type"
}

variable "jenkins_datadisk_size_gb" {
  description = "app/data disk size (in gb)"
}

################################################
################ Locals
################################################

locals {
  jenkins_tags = merge(
    module.global_common_base.common_tags,
    module.global_common_base_compute.common_instance_scheduler_tags,
    module.global_common_base_compute.common_instance_linux_tags,
    {}
  )
  
  jenkins_ip_configuration_name = "ipconfig1"

  jenkins_hostnames = azurerm_linux_virtual_machine.jenkins.*.computer_name

  jenkins_ips = azurerm_network_interface.jenkins.*.private_ip_address
  
  jenkins_private_dns_short = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_sub]), 
    local.jenkins_hostnames
  )

  jenkins_private_dns_fqdns = formatlist(
    join(".", ["%s", module.management_common_base_network.base_dns_internal_domain_full]), 
    local.jenkins_hostnames
  )
}

################################################
################ DNS specifics
################################################

resource "azurerm_private_dns_a_record" "jenkins" {
  count = var.jenkins_instancecount

  name                = join(module.global_common_base.hostname_delimiter, [var.jenkins_hostname, count.index + 1 ])
  zone_name           = module.management_common_base_network.base_dns_internal_domain_full
  resource_group_name = module.management_common_base_network.data_azurerm_resource_group.name
  ttl                 = 300
  records             = [
    azurerm_network_interface.jenkins[count.index].private_ip_address
  ]
}

################################################
################ VM specifics
################################################

resource "azurerm_network_security_group" "jenkins" {
  name                    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.jenkins_hostname, "nsg" ] ) 
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
    local.jenkins_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.jenkins_hostname, "nsg" ] )
    }
  )
}

resource "azurerm_network_interface" "jenkins" {
  count = var.jenkins_instancecount
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.jenkins_hostname, "nic", count.index + 1 ] ) 
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  #internal_dns_name_ljenkinsl   = join(".", [ join(module.global_common_base.hostname_delimiter, [var.jenkins_hostname, count.index + 1 ]), module.management_common_base_network.base_dns_internal_domain_sub])

  ip_configuration {
    name                          = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.jenkins_hostname, "nic", count.index + 1, local.jenkins_ip_configuration_name ] ) 
    subnet_id                     = module.management_common_base_network.data_azurerm_subnet_management.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(
    local.jenkins_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, var.jenkins_hostname, "nic", count.index + 1 ] )
    }
  )
}

resource "azurerm_network_interface_security_group_association" "jenkins" {
  count = var.jenkins_instancecount

  network_interface_id      = azurerm_network_interface.jenkins[count.index].id
  network_security_group_id = azurerm_network_security_group.jenkins.id
}

data "template_file" "setup-jenkins" {
  count    = var.jenkins_instancecount
  template = file("./resources/setup-server.sh")
}

resource "azurerm_managed_disk" "jenkins" {
  count    = var.jenkins_instancecount
  
  name                 = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.jenkins_hostname, count.index + 1] ), "disk1" ] ) 
  resource_group_name  = module.management_common_base_network.data_azurerm_resource_group.name
  location             = module.management_common_base_network.data_azurerm_resource_group.location
  storage_account_type = var.jenkins_datadisk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.jenkins_datadisk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "jenkins" {
  count    = var.jenkins_instancecount
  
  managed_disk_id    = azurerm_managed_disk.jenkins[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.jenkins[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_linux_virtual_machine" "jenkins" {
  count    = var.jenkins_instancecount
  
  name                      = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.jenkins_hostname, count.index + 1] ) ] ) 
  computer_name             = join("", [ join("", [var.jenkins_hostname, count.index + 1 ]) ] )
  resource_group_name       = module.management_common_base_network.data_azurerm_resource_group.name
  location                  = module.management_common_base_network.data_azurerm_resource_group.location
  size                      = var.jenkins_instancesize
  admin_username                  = var.common_compute_vm_linux.os_admin_user
  disable_password_authentication = true
  custom_data                     = base64encode(data.template_file.setup-jenkins[count.index].rendered)

  network_interface_ids = [
    azurerm_network_interface.jenkins[count.index].id
  ]

  admin_ssh_key {
    username   = var.common_compute_vm_linux.os_admin_user
    public_key = file(module.management_common_base_security.ssh_bastion_publickey_path)
  }

  os_disk {
    name                 = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, join("", [var.jenkins_hostname, count.index + 1] ) , "osdisk" ] )
    storage_account_type = var.jenkins_osdisk_storage_account_type
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = var.common_compute_vm_linux.os_image.publisher
    offer     = var.common_compute_vm_linux.os_image.offer
    sku       = var.common_compute_vm_linux.os_image.sku
    version   = var.common_compute_vm_linux.os_image.version
  }
  
  tags = merge(
    local.jenkins_tags,
    {
      "Name" = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_long, join("", [var.jenkins_hostname, count.index + 1] ) ] )
    }
  )
}

################################################
################ Load Balancer
################################################

## protected management external load balancer
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "jenkins_managementexternal" {
  count    = var.jenkins_instancecount
  
  ip_configuration_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.jenkins_hostname, "nic", count.index + 1, local.jenkins_ip_configuration_name ] )
  network_interface_id    = azurerm_network_interface.jenkins[count.index].id
  backend_address_pool_id = module.management_common_base_loadbalancing.appgateway_backend_address_pool_id_jenkins
}