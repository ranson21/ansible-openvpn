packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1.1.1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1.1.0"
    }
  }
}

source "googlecompute" "vpn_server" {
  project_id          = var.project_id
  source_image_family = "debian-11"
  zone                = var.zone
  network             = var.network
  ssh_username        = "packer"
  image_name          = "vpn-server-{{timestamp}}"
  image_description   = "OpenVPN server with web interface"
  image_family        = "vpn-server"

  // Use a small machine type for building
  machine_type = "e2-medium"

  // Enable IAP tunnel
  use_iap = true

  // Use OS Login
  metadata = {
    enable-oslogin = "TRUE"
  }
}

build {
  sources = ["source.googlecompute.vpn_server"]

  provisioner "ansible" {
    playbook_file = "./playbooks/vpn_server.yml"
    user          = "packer"
    use_proxy     = false
    extra_arguments = [
      "-v",
      "--extra-vars",
      "ansible_python_interpreter=/usr/bin/python3"
    ]
  }
}