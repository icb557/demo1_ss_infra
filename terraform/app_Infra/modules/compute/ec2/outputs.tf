output "instance_id" {
  value = aws_instance.app_server1.id
}

output "public_ip" {
  value = aws_instance.app_server1.public_ip
}

# output "key_pair_id" {
#   value = aws_key_pair.ec2_key_pair.id
# }