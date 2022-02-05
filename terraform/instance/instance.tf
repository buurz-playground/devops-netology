variable image { default =  "centos-8" }
variable name { default = ""}
variable description { default =  "instance from terraform" }
variable instance_role { default =  "all" }
variable users { default = "centos"}
variable cores { default = ""}
variable platform_id { default = "standard-v1"}
variable memory { default = ""}
variable core_fraction { default = "20"}
variable subnet_id { default = ""}
variable nat { default = "false"}
variable count_offset { default = 0 }
variable count_format { default = "%01d" }
variable boot_disk { default =  "network-hdd" }
variable disk_size { default =  "20" }

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.70.0"
    }
  }
}

data "yandex_compute_image" "image" {
  family = "${var.image}"
}

resource "yandex_compute_instance" "instance" {
  name = "${var.name}"
  platform_id = "${var.platform_id}"
  hostname = "${var.name}"
  description = "${var.description}"


  resources {
    cores  = "${var.cores}"
    memory = "${var.memory}"
    core_fraction = "${var.core_fraction}"
  }
  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.image.id}"
      type = "${var.boot_disk}"
      size = "${var.disk_size}"
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
  }

  metadata = {
    ssh-keys = "${var.users}:${file("~/.ssh/id_rsa.pub")}"
  }
}
