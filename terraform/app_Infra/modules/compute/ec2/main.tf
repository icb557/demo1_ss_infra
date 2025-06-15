# resource "aws_key_pair" "ec2_key_pair" {
#   key_name   = var.key_name
#   public_key = var.public_key
# }

data "template_file" "env_vars" {
  template = file("${path.module}/templates/env-vars.tpl")
  vars = {
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
    DB_HOST     = var.db_host
    DB_PORT     = var.db_port
    DB_NAME     = var.db_name
    TEST_DB_NAME = var.test_db_name
  }
}

resource "aws_instance" "app_server1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "ec2_key_pair"
  user_data = data.template_file.env_vars.rendered

  network_interface {
    network_interface_id = var.network_interface_id
    device_index         = 0
  }

  tags = var.tags

  provisioner "local-exec" {
    command = templatefile("${path.module}/templates/${var.host_os}-hosts.tpl", {
      hostname     = self.public_ip
      user         = var.ssh_user
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }
}