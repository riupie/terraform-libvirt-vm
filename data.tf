data "template_file" "network_config" {
  count    = var.vm_count
  template = file("${path.module}/templates/network_config_${var.dhcp ? "dhcp" : "static"}.tpl")

  vars = {
    interfaces = lookup(var.network_interfaces, count.index, [])
  }
}