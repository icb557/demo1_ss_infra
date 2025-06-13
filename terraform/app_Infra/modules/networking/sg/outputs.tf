output "app_server_sg_id" {
  value = aws_security_group.app_server_sg.id
}

output "db_server_sg_id" {
  value = aws_security_group.db_server_sg.id
} 