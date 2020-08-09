data "template_file" "jenkins_inventory_entry" {
  count    = length(local.jenkins_hostnames)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = "jenkins"
    index =  tostring(count.index + 1)
    ip = local.jenkins_ips[count.index]
    hostname = local.jenkins_hostnames[count.index]
    dns = local.jenkins_private_dns_fqdns[count.index]
  }
}

data "template_file" "deployer_inventory_entry" {
  count    = length(local.deployer_hostnames)
  template = file("${path.cwd}/resources/ansible-inventory-entry.template")
  vars = {
    alias = "deployer"
    index =  tostring(count.index + 1)
    ip = local.deployer_ips[count.index]
    hostname = local.deployer_hostnames[count.index]
    dns = local.deployer_private_dns_fqdns[count.index]
  }
}

data "template_file" "ansible_inventory" {
  template = file("${path.cwd}/resources/ansible-inventory.template")
  vars = {
    jenkins_servers = join("\n", data.template_file.jenkins_inventory_entry.*.rendered)
    deployer_servers = join("\n", data.template_file.deployer_inventory_entry.*.rendered)
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
      join("_", [ "inventory",module.global_common_base.name_prefix_long_nouuid ] )
    ]
  )
}