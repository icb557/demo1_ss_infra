resource "aws_network_interface" "ec2_nic1_as1" {
  subnet_id       = var.subnet_id
  private_ips     = var.private_ips
  security_groups = var.security_group_ids

  tags = {
    Name = "ec2_nic1_as1"
  }
}