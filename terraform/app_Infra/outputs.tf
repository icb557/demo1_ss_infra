output "app_server1_public_ip" {
  value = module.app_server1.public_ip
}

output "db_instance_endpoint" {
  value = module.db_server1.db_instance_endpoint
}

output "db_port" {
  value = module.db_server1.db_port
}