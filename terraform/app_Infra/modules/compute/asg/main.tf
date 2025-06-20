data "template_file" "app_setup" {
  template = file("${path.module}/templates/app-setup.tpl")
  vars = {
    DB_HOST     = local.db_endpoint
    DB_PORT     = local.db_port
    DB_PASSWORD = var.db_password
    DB_USER     = var.db_user
    DB_NAME     = var.db_name
  }
}

resource "aws_launch_template" "app_launch_template" {
  name_prefix   = var.name_prefix
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = base64encode(data.template_file.app_setup.rendered)
  vpc_security_group_ids = var.security_group_ids
  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = var.name
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = 300
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = false
  }
}

# Data source to get ASG instances
data "aws_instances" "asg_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = aws_autoscaling_group.app_asg.name
  }
  depends_on = [aws_autoscaling_group.app_asg]
}

# Create db_endpoint.txt file with database endpoint
resource "null_resource" "create_db_endpoint_file" {
  triggers = {
    db_endpoint = local.db_endpoint
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/templates/${var.host_os}-db-endpoint.tpl", {
      DB_HOST = local.db_endpoint
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }
}

# Create hosts.ini file with ASG instance IPs
resource "null_resource" "create_hosts_file" {
  triggers = {
    instance_count = length(data.aws_instances.asg_instances.ids)
    instance_ips   = join(",", data.aws_instances.asg_instances.public_ips)
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/templates/${var.host_os}-hosts.tpl", {
      instances = [
        for i, ip in data.aws_instances.asg_instances.public_ips : {
          hostname = ip
          user     = "ubuntu"
        }
      ]
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }

  depends_on = [data.aws_instances.asg_instances]
} 