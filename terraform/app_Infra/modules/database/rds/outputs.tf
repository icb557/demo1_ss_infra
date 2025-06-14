output "db_instance_id" {
  value = aws_db_instance.primary_db.id
}

output "db_instance_endpoint" {
  value = aws_db_instance.primary_db.endpoint
}

output "db_port" {
  value = aws_db_instance.primary_db.port
}