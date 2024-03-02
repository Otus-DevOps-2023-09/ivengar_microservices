terraform {
required_providers {
yandex = {
source = "yandex-cloud/yandex"
}
}
required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.ya_token
 ####service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "master" {
  source          = "./modules/master"
  public_key_path = var.public_key_path
  kubm_image_id   = var.kubm_image_id
  subnet_id       = var.subnet_id
}

module "worker" {
  source          = "./modules/worker"
  public_key_path = var.public_key_path
  kubw_image_id   = var.kubw_image_id
  subnet_id       = var.subnet_id
}
