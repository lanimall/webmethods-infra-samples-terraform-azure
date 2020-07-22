data "template_file" "bastion_linux_inventory_entry" {
  count    = length(local.bastion_linux_hostnames)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = "bastion_linux"
    index =  tostring(count.index + 1)
    ip = local.bastion_linux_ips[count.index]
    hostname = local.bastion_linux_hostnames[count.index]
    dns = local.bastion_linux_private_dns_fqdns[count.index]
  }
}

data "template_file" "bastion_windows_inventory_entry" {
  count    = length(local.bastion_windows_hostnames)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = "bastion_windows"
    index =  tostring(count.index + 1)
    ip = local.bastion_windows_ips[count.index]
    hostname = local.bastion_windows_hostnames[count.index]
    dns = local.bastion_windows_private_dns_fqdns[count.index]
  }
}

data "template_file" "management_linux_inventory_entry" {
  count    = length(local.management_linux_hostnames)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = "management_linux"
    index =  tostring(count.index + 1)
    ip = local.management_linux_ips[count.index]
    hostname = local.management_linux_hostnames[count.index]
    dns = local.management_linux_private_dns_fqdns[count.index]
  }
}

data "template_file" "management_windows_inventory_entry" {
  count    = length(local.management_windows_hostnames)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = "management_windows"
    index =  tostring(count.index + 1)
    ip = local.management_windows_ips[count.index]
    hostname = local.management_windows_hostnames[count.index]
    dns = local.management_windows_private_dns_fqdns[count.index]
  }
}

data "template_file" "ansible_inventory" {
  template = file("${path.cwd}/resources/ansible-inventory.template")
  vars = {
    bastion_linux_servers = join("\n", data.template_file.bastion_linux_inventory_entry.*.rendered)
    bastion_windows_servers = join("\n", data.template_file.bastion_windows_inventory_entry.*.rendered)
    management_linux_servers = join("\n", data.template_file.management_linux_inventory_entry.*.rendered)
    management_windows_servers = join("\n", data.template_file.management_windows_inventory_entry.*.rendered)
  }
}

resource "local_file" "ansible_inventory" {
  count    = (var.inventory_output_file_write == "true") ? 1 : 0
  
  content  = data.template_file.ansible_inventory.rendered
  filename = join(
    "/",
    [
      path.cwd,
      var.inventory_output_dir,
      join("_", [ "inventory", module.global_common_base.name_prefix_long_nouuid ] )
    ]
  )
}