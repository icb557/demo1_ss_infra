resource "aws_vpc" "cicd" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "cicd"
    Env  = "${var.env}"
  }
}

resource "aws_subnet" "cicd_public_subnet1" {
  vpc_id                  = aws_vpc.cicd.id
  cidr_block              = var.public_subnets.public_subnet1.cidr
  availability_zone       = var.public_subnets.public_subnet1.az
  map_public_ip_on_launch = true

  tags = {
    Name = "cicd_public_subnet1"
    Env  = "${var.env}"
  }
}

resource "aws_internet_gateway" "cicd_igw" {
  vpc_id = aws_vpc.cicd.id

  tags = {
    Name = "cicd_igw"
    Env  = "${var.env}"
  }
}

resource "aws_route_table" "cicd_public_rt" {
  vpc_id = aws_vpc.cicd.id

  tags = {
    Name = "cicd_public_subnet1_rt"
    Env  = "${var.env}"
  }
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.cicd_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cicd_igw.id
}

resource "aws_route_table_association" "cicd_public_rt_assoc" {
  subnet_id      = aws_subnet.cicd_public_subnet1.id
  route_table_id = aws_route_table.cicd_public_rt.id
}

resource "aws_network_acl" "cicd_public_sub_acl" {
  vpc_id = aws_vpc.cicd.id

  tags = {
    Name = "cicd_public_sub_acl"
    Env  = "${var.env}"
  }
}

resource "aws_network_acl_rule" "allow_in_http_acl" {
  network_acl_id = aws_network_acl.cicd_public_sub_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "allow_in_https_acl" {
  network_acl_id = aws_network_acl.cicd_public_sub_acl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "allow_in_ssh_acl" {
  count          = length(var.allowed_ips)
  network_acl_id = aws_network_acl.cicd_public_sub_acl.id
  rule_number    = 120 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.allowed_ips[count.index]
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "allow_in_jenkins_acl" {
  network_acl_id = aws_network_acl.cicd_public_sub_acl.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 8080
  to_port        = 8080
}

resource "aws_network_acl_rule" "allow_in_ephemeral_ports_acl" {
  network_acl_id = aws_network_acl.cicd_public_sub_acl.id
  rule_number    = 140
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "allow_out_pub_sub_acl" {
  network_acl_id = aws_network_acl.cicd_public_sub_acl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "allow_inner_out_pub_sub_acl" {
  network_acl_id = aws_network_acl.cicd_public_sub_acl.id
  rule_number    = 110
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_association" "cicd_public_sub_acl_assoc" {
  network_acl_id = aws_network_acl.cicd_public_sub_acl.id
  subnet_id      = aws_subnet.cicd_public_subnet1.id
}

resource "aws_security_group" "cicd_server_sg" {
  name        = "cicd_server_sg"
  description = "Manage inbound and outbound traffic for the ci/cd servers"
  vpc_id      = aws_vpc.cicd.id

  tags = {
    Env = "${var.env}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_in_http_traffic" {
  security_group_id = aws_security_group.cicd_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Allow inbound HTTP from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_in_https_traffic" {
  security_group_id = aws_security_group.cicd_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow inbound HTTPS from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_in_ssh_traffic" {
  for_each          = toset(var.allowed_ips)
  security_group_id = aws_security_group.cicd_server_sg.id
  cidr_ipv4         = each.value
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "Allow inbound SSH from admins IPs"
}

resource "aws_vpc_security_group_ingress_rule" "allow_in_http_jenkins_traffic" {
  security_group_id = aws_security_group.cicd_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
  description       = "Allow inbound HTTP to access jenkins"
}

resource "aws_vpc_security_group_egress_rule" "allow_out_cicd_server_traffic" {
  security_group_id = aws_security_group.cicd_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "-1"
  to_port           = -1
  description       = "Allow outbound traffic to anywhere"
}

resource "aws_key_pair" "cicd_ec2_key" {
  key_name   = "cicd_ec2_key"
  public_key = file("~/.ssh/cicdEc2Key.pub")
}

resource "aws_network_interface" "ec2_nic1_as1" {
  subnet_id       = aws_subnet.cicd_public_subnet1.id
  private_ips     = ["20.0.0.100"]
  security_groups = [aws_security_group.cicd_server_sg.id]

  tags = {
    Name = "ec2_nic1_cicd_server1"
  }
}

resource "aws_instance" "cicd_server1" {
  ami           = data.aws_ami.server_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.cicd_ec2_key.id
  user_data     = file("userdata.tpl")

  network_interface {
    network_interface_id = aws_network_interface.ec2_nic1_as1.id
    device_index         = 0
  }

  tags = {
    Name = "cicd_server1"
    Env  = "${var.env}"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip
      user         = "ubuntu"
      identityfile = "~/.ssh/cicdEc2Key"
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }
}

resource "aws_ebs_volume" "jenkins_volume" {
  availability_zone = aws_subnet.cicd_public_subnet1.availability_zone
  size              = 8
  type              = "gp2"
  tags = {
    Name = "jenkins-ebs-volume"
    Env  = var.env
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.jenkins_volume.id
  instance_id = aws_instance.cicd_server1.id
}