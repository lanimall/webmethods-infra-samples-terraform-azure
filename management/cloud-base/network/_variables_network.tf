### network default prefix to use
variable "network_cidr_prefix" {
  description = "The CIDR block first 2 octets for the Network"
}

### network default suffix to use
variable "network_cidr_suffix" {
  description = "The CIDR block last 2 octets for the Network"
}

variable "subnet_allocation_map_suffixes" {
  description = "Map of CIDR blocks to carve into subnets based on size"
}

### subnets sizes
variable "subnet_allocation_newbit_size" {
  description = "Map the friendly name to our subnet bit mask"
}

variable "dns_internal_topdomain" {
  description = "top domain of the internal DNS"
}

variable "dns_internal_subdomain" {
  description = "sub domain for the internal DNS"
}

variable "subnet_shortname_dmz" {
  description = "name of the DMZ subnet"
}

variable "subnet_shortname_dmz_size" {
  description = "size of the DMZ subnet"
}

variable "subnet_shortname_dmz_index" {
  description = "the subnet index within the type of sized subnet"
}

variable "subnet_shortname_bastion" {
  description = "name of the bastion subnet"
}

variable "subnet_shortname_bastion_size" {
  description = "size of the bastion subnet"
}

variable "subnet_shortname_bastion_index" {
  description = "the subnet index within the type of sized subnet"
}

variable "subnet_shortname_management" {
  description = "name of the Management subnet"
}

variable "subnet_shortname_management_size" {
  description = "size of the management subnet"
}

variable "subnet_shortname_management_index" {
  description = "the subnet index within the type of sized subnet"
}

variable "subnet_shortname_firewall" {
  description = "name of the subnet"
}

variable "subnet_shortname_firewall_size" {
  description = "size of the subnet"
}

variable "subnet_shortname_firewall_index" {
  description = "the subnet index within the type of sized subnet"
}