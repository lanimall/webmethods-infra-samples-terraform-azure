data "template_file" "setenv-bastion" {
  template = file("${path.cwd}/resources/setenv-bastion.template")
  vars = {
    bastion_linux_1_user                = var.common_compute_vm_linux.os_admin_user
    bastion_linux_1_hostname_public     = length(azurerm_public_ip.bastion_linux)>0 ? azurerm_public_ip.bastion_linux.0.ip_address : "null"

    bastion_windows_1_user              = var.common_compute_vm_windows.os_admin_user
    bastion_windows_1_hostname_public   = length(azurerm_public_ip.bastion_windows)>0 ? azurerm_public_ip.bastion_windows.0.ip_address : "null"
  }
}

resource "local_file" "setenv-bastion" {
  content  = data.template_file.setenv-bastion.rendered
  filename = join("/", [ pathexpand(var.env_output_dir), "setenv-bastion.sh" ] )
}

data "template_file" "setenv-management" {
  template = file("${path.cwd}/resources/setenv-management.template")
  vars = {
    management_linux_1_user     = var.common_compute_vm_linux.os_admin_user
    management_linux_1_hostname_private = length(azurerm_network_interface.management_linux)>0 ? azurerm_network_interface.management_linux.0.private_ip_address : "null"
  }
}

resource "local_file" "setenv-management" {
  content  = data.template_file.setenv-management.rendered
  filename = join("/", [ pathexpand(var.env_output_dir), "setenv-management.sh" ] )
}