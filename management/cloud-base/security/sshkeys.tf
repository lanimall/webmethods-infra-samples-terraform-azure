############# ssh keys ############

output "ssh_bastion_publickey_path" {
  value = local.ssh_bastion_publickey_path
}

output "ssh_internal_publickey_path" {
  value = local.ssh_bastion_publickey_path
}

locals {
  ssh_bastion_publickey_path  = var.ssh_bastion_publickey_path
  ssh_internal_publickey_path = var.ssh_internal_publickey_path
}