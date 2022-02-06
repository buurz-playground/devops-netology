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
  instance_count = local.news_instance_count[terraform.workspace]

  subnet_id     = "${var.yc_subnet_id}"
  image         = "centos-8"
  platform_id   = "standard-v2"
  name          = "news"
  description   = "News App Demo"
  instance_role = "news,balancer"
  users         = "centos"
  cores         = local.news_cores[terraform.workspace]
  boot_disk     = "network-ssd"
  disk_size     = local.news_disk_size[terraform.workspace]
  nat           = "true"
  memory        = "2"
  core_fraction = "50"
}

module "feed" {
  source = "../modules/feed"

  for_each = {
    stage = 1
    prod = 2
  }

  instance_count = terraform.workspace == each.key ? each.value : 0

  subnet_id     = "${var.yc_subnet_id}"
  image         = "centos-8"
  platform_id   = "standard-v2"
  name          = "feed"
  description   = "Feed"
  instance_role = "feed"
  users         = "centos"
  cores         = local.feed_cores[terraform.workspace]
  boot_disk     = "network-ssd"
  disk_size     = local.feed_disk_size[terraform.workspace]
  nat           = "true"
  memory        = "2"
  core_fraction = "50"
}

locals {
  news_cores = {
    stage = 2
    prod = 2
  }
  news_disk_size = {
    stage = 20
    prod = 40
  }
  news_instance_count = {
    stage = 1
    prod = 2
  }

  feed_cores = {
    stage = 2
    prod = 2
  }
  feed_disk_size = {
    stage = 20
    prod = 40
  }
  vpc_subnets = {
    stage = [
      {
        "v4_cidr_blocks": [
          "10.128.0.0/24"
        ],
        "zone": var.yc_region
      }
    ]
    prod = [
      {
        zone           = "ru-central1-a"
        v4_cidr_blocks = ["10.128.0.0/24"]
      },
      {
        zone           = "ru-central1-b"
        v4_cidr_blocks = ["10.129.0.0/24"]
      },
      {
        zone           = "ru-central1-c"
        v4_cidr_blocks = ["10.130.0.0/24"]
      }
    ]
  }
}
