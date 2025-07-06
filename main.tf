terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.7.0"
    }
  }
}

resource "libvirt_domain" "virt-machine" {
  count  = var.vm_count
  name   = format("${var.vm_hostname_prefix}%02d", count.index + var.index_start)
  memory = var.memory
  cpu {
    mode = var.cpu_mode
  }
  vcpu       = var.vcpu
  autostart  = var.autostart
  qemu_agent = true

  cloudinit = element(libvirt_cloudinit_disk.commoninit[*].id, count.index)

  network_interface {
    network_name   = var.network_name
    wait_for_lease = true
    hostname       = format("${var.vm_hostname_prefix}%02d", count.index + var.index_start)
  }

  xml {
    xslt = templatefile("${path.module}/xslt/template.tftpl", var.xml_override)
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = element(libvirt_volume.volume-qcow2[*].id, count.index)
  }

  # Attach legacy additional_disk_ids (old way)
  dynamic "disk" {
    for_each = local.use_new_disk_mode ? [] : var.additional_disk_ids
    content {
      volume_id = disk.value
    }
  }

  # Attach new auto-created volumes (global or per-VM)
  dynamic "disk" {
    for_each = local.use_new_disk_mode ? {
      for idx, vol in libvirt_volume.additional :
      idx => vol
      if !var.attach_individual_disks_per_vm || local.flattened_disks[idx].vm_index == count.index
    } : {}

    content {
      volume_id = disk.value.id
    }
  }

  dynamic "filesystem" {
    for_each = var.share_filesystem.source != null ? [var.share_filesystem.source] : []
    content {
      source     = var.share_filesystem.source
      target     = var.share_filesystem.target
      readonly   = var.share_filesystem.readonly
      accessmode = var.share_filesystem.mode
    }
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"Virtual Machine \"$(hostname)\" is UP!\"",
      "date"
    ]
    connection {
      type                = "ssh"
      user                = var.ssh_admin
      host                = self.network_interface[0].addresses[0]
      private_key         = try(file(var.ssh_private_key), var.ssh_private_key, null)
      timeout             = "2m"
      bastion_host        = var.bastion_host
      bastion_user        = var.bastion_user
      bastion_private_key = try(file(var.bastion_ssh_private_key), var.bastion_ssh_private_key, null)
    }
  }
  lifecycle {
    precondition {
      condition     = !(length(var.additional_disk_ids) > 0 && length(var.additional_disks) > 0)
      error_message = "Cannot set both additional_disk_ids and additional_disks. Choose one."
    }
  }
}

# Additional libvirt volume
resource "libvirt_volume" "additional" {
  count  = local.use_new_disk_mode ? length(local.flattened_disks) : 0
  name   = local.flattened_disks[count.index].name
  size   = local.flattened_disks[count.index].size
  format = local.flattened_disks[count.index].format
  pool   = var.base_pool_name
}
