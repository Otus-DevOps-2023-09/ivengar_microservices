variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable "public_key_path" {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable "kubm_image_id" {
  description = "Disk image master"
}
variable "kubw_image_id" {
  description = "Disk image worker"
}
variable "subnet_id" {
  description = "Subnet"
}
# variable "service_account_key_file" {
#  description = "key .json"
#}
variable "privat_key_path" {
  # Описание переменной
  description = "Path to the privat key used for connection section"
}
variable "ya_token" {
}
