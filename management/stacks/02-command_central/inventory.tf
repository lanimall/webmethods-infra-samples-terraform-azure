data "template_file" "commandcentral_inventory_entry" {
  count    = length(local.commandcentral_hostnames)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = "commandcentral"
    index =  tostring(count.index + 1)
    ip = local.commandcentral_ips[count.index]
    hostname = local.commandcentral_hostnames[count.index]
    dns = local.commandcentral_private_dns_fqdns[count.index]
  }
}

data "template_file" "ansible_inventory" {
  template = file("${path.cwd}/resources/ansible-inventory.template")
  vars = {
    commandcentral_servers = join("\n", data.template_file.commandcentral_inventory_entry.*.rendered)
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