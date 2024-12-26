locals {
  user_dir  = "${var.home_path}/${var.user}"
  local_bin = "${local.user_dir}/.local/bin"

  galaxy_command   = "/usr/bin/ansible-galaxy"
  command          = "$HOME/.local/bin/ansible-playbook"
  ansible_work_dir = "$HOME/ansible-temp"
}


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

  ssh_username = "packer"
  # temporary_key_pair_type = "rsa"
  # temporary_key_pair_bits = 2048
  # wait_to_add_ssh_keys    = "20s"

  image_name        = "vpn-server-{{timestamp}}"
  image_description = "OpenVPN server with web interface"
  image_family      = "vpn-server"

  // Use a small machine type for building
  machine_type = "e2-medium"

  # Use OS Login instead of IAP tunneling
  use_os_login = true
}

build {
  sources = ["source.googlecompute.vpn_server"]

  provisioner "shell" {
    inline = [
      "mkdir -p ${local.ansible_work_dir}",
    ]
  }

  provisioner "file" {
    source      = "../playbooks/roles"
    destination = "${local.ansible_work_dir}/roles"
  }


  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3.9 python3-pip",
      "pip3 install --user ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_file     = "../playbooks/vpn_server.yml"
    command           = local.command
    staging_directory = local.ansible_work_dir


    extra_arguments = [
      "--ssh-extra-args='o StrictHostKeyChecking=no'",
      "-v",
      "--extra-vars",
      "ansible_python_interpreter=/usr/bin/python3"
    ]

    clean_staging_directory = true
  }
}