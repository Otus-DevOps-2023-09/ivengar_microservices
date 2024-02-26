output "external_ip_address_master" {
  value = module.master.external_ip_address_master
}
output "external_ip_address_worker" {
  value = module.worker.external_ip_address_worker
}
