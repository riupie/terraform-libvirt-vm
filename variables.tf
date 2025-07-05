variable "os_img_url" {
  description = "URL to the OS image"
  type        = string
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "base_volume_name" {
  description = "Name of base OS image"
  type        = string
  default     = null
}

variable "base_pool_name" {
  description = "Name of pool OS image"
  type        = string
  default     = null
}

variable "additional_disk_ids" {
  description = "List of existing libvirt_volume IDs to attach to each VM"
  type        = list(string)
  default     = []
}

variable "additional_disks" {
  description = <<EOT
New format: list of disk definitions (global or per-VM).
If `attach_individual_disks_per_vm = true`, must be a map of VM index to list of disks.
EOT
  type = any
  default = []
}

variable "attach_individual_disks_per_vm" {
  description = "If true, attach additional disks per VM index using additional_disks map"
  type        = bool
  default     = false
}


variable "autostart" {
  description = "Autostart the domain"
  type        = bool
  default     = true
}

variable "vm_count" {
  description = "Number of VMs"
  type        = number
  default     = 1
}

variable "index_start" {
  description = "From where the indexig start"
  type        = number
  default     = 1
}

variable "vm_hostname_prefix" {
  description = "VM hostname prefix"
  type        = string
  default     = "vm"
}

variable "memory" {
  description = "RAM in MB"
  type        = string
  default     = "1024"
}

variable "cpu_mode" {
  description = "CPU mode"
  type        = string
  default     = "host-passthrough"
}

variable "xml_override" {
  description = "With these variables you can: Enable hugepages; Set USB controllers; Attach USB devices"
  type = object({
    hugepages = bool
    usb_controllers = list(object({
      model = string
    }))
    usb_devices = list(object({
      vendor  = string
      product = string
    }))
    pci_devices_passthrough = list(object({
      src_domain = string
      src_bus    = string
      src_slot   = string
      src_func   = string
      dst_domain = string
      dst_bus    = string
      dst_slot   = string
      dst_func   = string
    }))
  })
  default = {

    hugepages = false,

    usb_controllers = [
      {
        model = "piix3-uhci"
      }
    ],

    usb_devices = [
      # {
      #   vendor = "0x0123",
      #   product = "0xabcd"
      # }
    ],
    pci_devices_passthrough = [
      #{
      #  src_domain = "0x0000",
      #  src_bus = "0xc1",
      #  src_slot = "0x00",
      #  src_func = "0x0",
      #  dst_domain = "0x0000",
      #  dst_bus = "0x00",
      #  dst_slot = "0x08"
      #  dst_func = "0x0"
      #}
    ]
  }

}

variable "vcpu" {
  description = "Number of vCPUs"
  type        = number
  default     = 1
}

variable "pool" {
  description = "Storage pool name"
  type        = string
  default     = "default"
}

variable "system_volume" {
  description = "System Volume size (GB)"
  type        = number
  default     = 10
}

variable "share_filesystem" {
  type = object({
    source   = string
    target   = string
    readonly = bool
    mode     = string
  })
  default = {
    source   = null
    target   = null
    readonly = false
    mode     = null
  }
}

variable "dhcp" {
  description = "Use DHCP or Static IP settings"
  type        = bool
  default     = false
}

variable "network_name" {
  description = "Network name"
  type        = string
  default     = "default"
}

variable "ip_address" {
  description = "List of IP addresses"
  type        = list(string)
  default     = ["192.168.123.101"]
}

variable "ip_nameserver" {
  description = "IP addresses of a nameserver"
  type        = string
  default     = "192.168.123.1"
}

variable "ip_gateway" {
  description = "IP addresses of a gateway"
  type        = string
  default     = "192.168.123.1"
}

variable "ssh_admin" {
  description = "Admin user with ssh access"
  type        = string
  default     = "ssh-admin"
}

variable "ssh_keys" {
  description = "List of public ssh keys"
  type        = list(string)
  default     = []
}

variable "local_admin" {
  description = "Admin user without ssh access"
  type        = string
  default     = ""
}

variable "local_admin_passwd" {
  description = "Local admin user password"
  type        = string
  default     = "password_example"
}

variable "time_zone" {
  description = "Time Zone"
  type        = string
  default     = "UTC"
}

variable "ssh_private_key" {
  description = "Private key for SSH connection test (either path to file or key content)"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "runcmd" {
  description = "Extra commands to be run with cloud init"
  type        = list(string)
  default = [
    "[ systemctl, daemon-reload ]",
    "[ systemctl, enable, qemu-guest-agent ]",
    "[ systemctl, start, qemu-guest-agent ]",
    "[ systemctl, restart, systemd-networkd ]"
  ]
}

variable "graphics" {
  description = "Graphics type"
  type        = string
  default     = "spice"

  validation {
    condition     = contains(["spice", "vnc"], var.graphics)
    error_message = "Graphics type not supported. Only 'spice' or 'vnc' are valid options."
  }
}

variable "bastion_host" {
  description = "Bastion host"
  type        = string
  default     = null
}

variable "bastion_user" {
  description = "Bastion ssh user"
  type        = string
  default     = null
}

variable "bastion_ssh_private_key" {
  description = "Bastion private key for SSH connection test (either path to file or key content)"
  type        = string
  default     = null
}

variable "disable_ipv6" {
  description = "Disable IPv6 on the instance"
  type        = bool
  default     = false
}