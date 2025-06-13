resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_instance" "app_server1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.ec2_key_pair.id

  network_interface {
    network_interface_id = var.network_interface_id
    device_index         = 0
  }

  tags = var.tags

  provisioner "local-exec" {
    command = templatefile("${path.module}/templates/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip
      user         = var.ssh_user
      identityfile = var.identity_file
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }
}