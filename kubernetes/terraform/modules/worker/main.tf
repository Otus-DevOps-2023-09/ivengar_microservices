terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
  }


resource "yandex_compute_instance" "worker" {
  name = "kubernetes-worker"

  labels = {
    tags = "kubernetes-worker"
  }
  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.kubw_image_id
      size     = 45
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat = true
  }

  metadata = {
  ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}
