data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "master" {
  name        = "k8s-master"
  hostname    = "k8s-master"
  zone        = var.default_zone
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet_a.id
    #security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  scheduling_policy {
    preemptible = false
  }
}

resource "yandex_compute_instance" "workers" {
  count       = 2
  name        = "k8s-worker-${count.index + 1}"
  hostname    = "k8s-worker-${count.index + 1}"
  zone        = var.zone_workers[count.index % length(var.zone_workers)]
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id  = count.index == 0 ? yandex_vpc_subnet.subnet_a.id : yandex_vpc_subnet.subnet_b.id
    #security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# resource "yandex_vpc_security_group" "k8s_sg" {
#   name        = "k8s-security-group"
#   network_id  = yandex_vpc_network.main.id
#   description = "Security group for Kubernetes"

#   ingress {
#     protocol       = "ANY"
#     description    = "all in subnet"
#     v4_cidr_blocks    = ["0.0.0.0/16"]
#   }

#   egress {
#     protocol       = "ANY"
#     description    = "all income"
#     v4_cidr_blocks    = ["0.0.0.0/0"]
#   }
# }