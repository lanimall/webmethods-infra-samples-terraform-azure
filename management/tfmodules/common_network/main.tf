###################### variables from base network

data "terraform_remote_state" "base_network" {
    backend = "s3"
    config = {
      bucket = var.s3_bucket_name
      key    = join(
                "/",
                [
                  var.project_name,
                  var.provider_name,
                  var.workload_name,
                  var.environment_level,
                  "network.tfstate"
                ]
              )
      region = var.s3_bucket_region
    }
}

locals {
  base_network_resource_group_main_id = data.terraform_remote_state.base_network.outputs.network_resource_group_main_id
  base_network_resource_group_main_name = data.terraform_remote_state.base_network.outputs.network_resource_group_main_name
  base_network_main_id = data.terraform_remote_state.base_network.outputs.network_main_id
  base_network_main_name = data.terraform_remote_state.base_network.outputs.network_main_name
  base_network_main_address_space = data.terraform_remote_state.base_network.outputs.network_main_address_space

  base_network_subnet_dmz_name=data.terraform_remote_state.base_network.outputs.network_subnet_dmz_name
  base_network_subnet_dmz_id=data.terraform_remote_state.base_network.outputs.network_subnet_dmz_id

  base_network_subnet_bastion_name=data.terraform_remote_state.base_network.outputs.network_subnet_bastion_name
  base_network_subnet_bastion_id=data.terraform_remote_state.base_network.outputs.network_subnet_bastion_id

  base_network_subnet_management_name=data.terraform_remote_state.base_network.outputs.network_subnet_management_name
  base_network_subnet_management_id=data.terraform_remote_state.base_network.outputs.network_subnet_management_id

  base_dns_internal_domain_full=data.terraform_remote_state.base_network.outputs.dns_internal_domain_full
  base_dns_internal_domain_top=data.terraform_remote_state.base_network.outputs.dns_internal_domain_top
  base_dns_internal_domain_sub=data.terraform_remote_state.base_network.outputs.dns_internal_domain_sub
}

###################### get the resource group and network

data "azurerm_resource_group" "main" {
  name = local.base_network_resource_group_main_name
}

data "azurerm_virtual_network" "main" {
  name                = local.base_network_main_name
  resource_group_name = local.base_network_resource_group_main_name
}

###################### Reference to the various networks

data "azurerm_subnet" "dmz" {
  name                 = local.base_network_subnet_dmz_name
  virtual_network_name = local.base_network_main_name
  resource_group_name  = local.base_network_resource_group_main_name
}

data "azurerm_subnet" "management" {
  name                 = local.base_network_subnet_management_name
  virtual_network_name = local.base_network_main_name
  resource_group_name  = local.base_network_resource_group_main_name
}

data "azurerm_subnet" "bastion" {
  name                 = local.base_network_subnet_bastion_name
  virtual_network_name = local.base_network_main_name
  resource_group_name  = local.base_network_resource_group_main_name
}