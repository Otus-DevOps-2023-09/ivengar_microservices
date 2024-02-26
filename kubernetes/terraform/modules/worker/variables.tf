variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable kubw_image_id {
  description = "Disk image for kubernetes worker"
  default = "kubernetes-base"
}
variable subnet_id {
  description = "Subnets for modules"
}
