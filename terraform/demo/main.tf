terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.70.0"
    }
  }
}

# Provider
provider "yandex" {
  token     = "${var.yc_token}"
  cloud_id  = "${var.yc_cloud_id}"
  folder_id = "${var.yc_folder_id}"
  zone      = "${var.yc_region}"
}


module "news" {
  source = "../modules/instance"

  subnet_id     = "${var.yc_subnet_id}"
  image         = "centos-8"
  platform_id   = "standard-v2"
  name          = "news"
  description   = "News App Demo"
  instance_role = "news,balancer"
  users         = "centos"
  cores         = "2"
  boot_disk     = "network-ssd"
  disk_size     = "20"
  nat           = "true"
  memory        = "2"
  core_fraction = "50"
}
