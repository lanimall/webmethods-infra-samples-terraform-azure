subnet_shortname_management="management"
subnet_shortname_management_size="small"
subnet_shortname_management_index="0"

subnet_shortname_bastion="bastion"
subnet_shortname_bastion_size="xxsmall"
subnet_shortname_bastion_index="0"

subnet_shortname_dmz="dmz"
subnet_shortname_dmz_size="xxsmall"
subnet_shortname_dmz_index="1"

## note: The name must be exactly 'AzureFirewallSubnet' to be used for the Azure Firewall resource
subnet_shortname_firewall="AzureFirewallSubnet"
subnet_shortname_firewall_size="xxsmall"
subnet_shortname_firewall_index="2"

# Note: the network_cidr_prefix will be given at runtime for security reasons

# Total size for the network
network_cidr_suffix="0.0/16"

### Distinct non-overalpping subnets spaces for different sizes of subnets
### each /19 = 8190 hosts
subnet_allocation_map_suffixes = {
    "xxsmall" = "0.0/19"
    "xsmall"  = "32.0/19"
    "small"  = "64.0/19"
    "medium" = "96.0/19"
    "large1"  = "128.0/19"
    "large2" = "160.0/19"
    "xlarge1"  = "192.0/19"
    "xlarge2" = "224.0/19"
}

### subnets sizes
#### 9 - results in /28 - 14 usable hosts (512 subnets into a /19 net)
#### 8 - results in /27 - 30 usable hosts (256 subnets into a /19 net)
#### 7 - results in /26 - 62 usable hosts (128 subnets into a /19 net)
#### 6 - results in /25 - 126 usable hosts (64 subnets into a /19 net)
#### 5 - results in /24 - 254 usable hosts (32 subnets into a /19 net)
#### 4 - results in /23 - 510 usable hosts (16 subnets into a /19 net)
subnet_allocation_newbit_size = {
    "xxsmall" = "9"
    "xsmall" = "8"
    "small" = "7"
    "medium"  = "6"
    "large1" = "5"
    "large2" = "5"
    "xlarge1"  = "4"
    "xlarge2"  = "4"
}