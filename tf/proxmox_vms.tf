variable "proxmox_container_template" {
  type    = string
  default = "local:vztmpl/reisen-ct-2024-01-26-nixos-system-x86_64-linux.tar.xz"
}

data "proxmox_virtual_environment_vm" "kubernetes" {
  node_name = "reisen"
  vm_id     = 201
}

resource "proxmox_virtual_environment_container" "reimu" {
  node_name = "reisen"
  vm_id     = 104
  tags      = ["tf"]

  memory {
    dedicated = 512
    swap      = 256
  }

  disk {
    datastore_id = "local-zfs"
    size         = 16
  }

  initialization {
    hostname = "reimu"
    ip_config {
      ipv6 {
        address = "auto"
      }
    }
  }

  network_interface {
    name        = "eth0"
    mac_address = "BC:24:11:C4:66:A8"
  }

  operating_system {
    template_file_id = var.proxmox_container_template
    type             = "nixos"
  }

  unprivileged = true
  features {
    nesting = true
  }

  console {
    type = "console"
  }
  started = false
}

resource "terraform_data" "proxmox_reimu_config" {
  depends_on = [
    proxmox_virtual_environment_container.reimu
  ]

  triggers_replace = [
    proxmox_virtual_environment_container.reimu.id
  ]

  connection {
    type     = "ssh"
    user     = var.proxmox_reisen_ssh_username
    password = var.proxmox_reisen_password
    host     = var.proxmox_reisen_ssh_host
    port     = var.proxmox_reisen_ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/infra/bin/lxc-config ${proxmox_virtual_environment_container.reimu.vm_id} unprivileged 0 features 'nesting=1,mount=nfs,mknod=1' lxc.mount.entry '/dev/net/tun dev/net/tun none bind,optional,create=file'",
    ]
  }
}
