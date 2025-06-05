output "cicd_server_public_ip" {
  value = aws_instance.cicd_server1.public_ip
}