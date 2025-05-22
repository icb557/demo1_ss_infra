output "app_server_public_ip" {
  value = aws_instance.demo1_app_server1.public_ip
}