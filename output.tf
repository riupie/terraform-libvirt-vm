output "name" {
  value = libvirt_domain.virt-machine[*].name
}
output "ip_address" {
  value = var.dhcp ? libvirt_domain.virt-machine[*].network_interface[0].addresses[0] : [for i in range(var.vm_count) : element(var.ip_address, i)]
}
