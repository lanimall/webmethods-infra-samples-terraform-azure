
################################################
################ outputs
################################################

output "azurerm_network_security_group_dmz_id" {
  value = azurerm_network_security_group.dmz.id
}

output "azurerm_network_security_group_management_id" {
  value = azurerm_network_security_group.management.id
}

output "azurerm_network_security_group_bastion_id" {
  value = azurerm_network_security_group.bastion.id
}

variable "subnet_bastion_allowed_source_ips" {
  description = "list of IPs allowed for the subnet"
}

################################################
################ security groups
################################################

resource "azurerm_network_security_group" "dmz" {
  name                  = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_dmz ] )
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location

  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = join("_", [ module.global_common_base.name_prefix_long, var.subnet_shortname_dmz ] )
    }
  )
}

################ inbound rules
################ notes: priority processing stops once a rule matches (and lower umber = processed first)

resource "azurerm_network_security_rule" "dmz-loadbalancer-inbound" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_dmz, "inbound", "loadbalancer" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.dmz.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["65200-65535"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "dmz-inbound" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_dmz, "inbound", "web" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.dmz.name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80","443"]
  source_address_prefixes     = flatten([
    var.subnet_bastion_allowed_source_ips
  ])
  destination_address_prefix  = "*"
}

################ outbound rules
################ notes: priority processing stops once a rule matches (and lower umber = processed first)
resource "azurerm_network_security_rule" "dmz-outbound" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_dmz, "outbound" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.dmz.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.dmz.address_prefix
  destination_address_prefixes = [
    "183.0.0.0/16", ## peered vnet
    local.main_cidr
  ]
}

resource "azurerm_network_security_group" "bastion" {
  name                  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.subnet_shortname_bastion ] )
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location

  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-bastion"
    }
  )
}

############### this was a nice example of using a loop with for_each... will keep here for example.

# resource "azurerm_network_security_rule" "bastion-inbound" {
#   for_each = var.subnet_bastion_allowed_source_ips

#   name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_bastion, "inbound", each.value ] )
#   resource_group_name         = azurerm_resource_group.main.name
#   network_security_group_name = azurerm_network_security_group.bastion.name
#   priority                    = each.value
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_ranges     = ["22","3389","8091"]
#   source_address_prefix       = each.key
#   destination_address_prefix  = "*"
# }

resource "azurerm_network_security_rule" "bastion-inbound-ssh" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_bastion, "inbound", "ssh" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.bastion.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22"]
  source_address_prefixes     = var.subnet_bastion_allowed_source_ips
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "bastion-inbound-winrdgateway-tcp" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_bastion, "inbound", "winrdgateway-tcp" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.bastion.name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["3389", "443"]
  source_address_prefixes     = var.subnet_bastion_allowed_source_ips
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "bastion-inbound-winrdgateway-udp" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_bastion, "inbound", "winrdgateway-udp" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.bastion.name
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_ranges     = ["3391"]
  source_address_prefixes     = var.subnet_bastion_allowed_source_ips
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "bastion-inbound-commandcentral" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_bastion, "inbound", "commandcentral" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.bastion.name
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["8090","8091"]
  source_address_prefixes     = var.subnet_bastion_allowed_source_ips
  destination_address_prefix  = "*"
}

################ outbound rules
################ notes: priority processing stops once a rule matches (and lower umber = processed first)
resource "azurerm_network_security_rule" "bastion-outbound" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_bastion, "outbound" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.bastion.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.bastion.address_prefix
  destination_address_prefix  = local.main_cidr
}

resource "azurerm_network_security_group" "management" {
  name                  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, var.subnet_shortname_management ] )
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location

  tags = merge(
    module.global_common_base.common_tags,
    {
      "Name" = "${module.global_common_base.name_prefix_long}-management"
    }
  )
}

################ inbound rules
################ notes: priority processing stops once a rule matches (and lower umber = processed first)
resource "azurerm_network_security_rule" "management-inbound" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_management, "inbound" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.management.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range     = "*"
  source_address_prefix       = local.main_cidr
  destination_address_prefix  = azurerm_subnet.management.address_prefix
}

################ outbound rules
################ notes: priority processing stops once a rule matches (and lower umber = processed first)
resource "azurerm_network_security_rule" "management-outbound" {
  name                        = join("_", [ module.global_common_base.name_prefix_short, var.subnet_shortname_management, "outbound" ] )
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.management.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.management.address_prefix
  destination_address_prefix  = local.main_cidr
}

################################################
################ extra sec-groups rules
################################################

