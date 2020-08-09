
output "ssh_internal_publickey_path" {
  value = data.terraform_remote_state.base_security.outputs.ssh_internal_publickey_path
}

output "ssh_bastion_publickey_path" {
  value = data.terraform_remote_state.base_security.outputs.ssh_bastion_publickey_path
}

output "azurerm_user_assigned_identity_mainappgateway_name" {
  value = data.terraform_remote_state.base_security.outputs.azurerm_user_assigned_identity_mainappgateway_name
}