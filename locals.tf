locals {
  all_keys = <<EOT
[
%{~for keys in var.ssh_keys~}
"${keys}",
%{~endfor~}
]
EOT
  runcmd   = <<EOT
%{for cmd in var.runcmd~}
  - ${cmd}
%{endfor~}
EOT

  use_new_disk_mode = length(var.additional_disks) > 0

  flattened_disks = var.attach_individual_disks_per_vm ? flatten([
    for vm_index, disks in var.additional_disks : [
      for disk_index, d in disks : {
        vm_index     = tonumber(vm_index)
        disk_index   = disk_index
        base_name    = d.name
        name         = (
          try(d.format, "qcow2") == "qcow2"
            ? "${d.name}-${vm_index}-${disk_index}.qcow2"
            : "${d.name}-${vm_index}-${disk_index}"
        )
        size   = d.size
        format = try(d.format, "qcow2")
      }
    ]
  ]) : [
    for i, d in var.additional_disks : {
      vm_index     = null
      disk_index   = i
      base_name    = d.name
      name         = (
        try(d.format, "qcow2") == "qcow2"
          ? "${d.name}-${i}.qcow2"
          : "${d.name}-${i}"
      )
      size   = d.size
      format = try(d.format, "qcow2")
    }
  ]

  volumes_by_vm_index = var.attach_individual_disks_per_vm ? {
    for vm_index in range(var.vm_count) : vm_index => [
      for disk in local.flattened_disks : disk.name
      if disk.vm_index == vm_index
    ]
  } : {}
}
