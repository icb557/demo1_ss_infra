resource "aws_vpc" "demo1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "demo1"
    Env  = "${var.env}"
  }
}

resource "aws_subnet" "demo1_public_subnet" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.demo1.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "demo1_${each.key}"
    Env  = "${var.env}"
  }
}

resource "aws_subnet" "demo1_private_subnet" {
  for_each                = var.private_subnets
  vpc_id                  = aws_vpc.demo1.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "demo1_${each.key}"
    Env  = "${var.env}"
  }
}

resource "aws_internet_gateway" "demo1_igw" {
  vpc_id = aws_vpc.demo1.id

  tags = {
    Name = "demo1_igw"
    Env  = "${var.env}"
  }
}

resource "aws_route_table" "demo1_public_rt" {
  vpc_id = aws_vpc.demo1.id

  tags = {
    Name = "demo1_public_subnets__rt"
    Env  = "${var.env}"
  }
}

resource "aws_route_table" "demo1_private_rt" {
  for_each = var.private_subnets
  vpc_id   = aws_vpc.demo1.id

  tags = {
    Name = "demo1_${each.key}_rt"
    Env  = "${var.env}"
  }
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.demo1_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.demo1_igw.id
}

resource "aws_route_table_association" "demo1_public_rt_assoc" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.demo1_public_subnet[each.key].id
  route_table_id = aws_route_table.demo1_public_rt.id
}

resource "aws_route_table_association" "demo1_private_rt_assoc" {
  for_each       = var.private_subnets
  subnet_id      = aws_subnet.demo1_private_subnet[each.key].id
  route_table_id = aws_route_table.demo1_private_rt[each.key].id
}

resource "aws_network_acl" "demo1_public_sub_acl" {
  vpc_id = aws_vpc.demo1.id

  tags = {
    Name = "demo1_public_sub_acl"
    Env  = "${var.env}"
  }
}

resource "aws_network_acl" "demo1_private_sub_acl" {
  vpc_id = aws_vpc.demo1.id

  tags = {
    Name = "demo1_private_sub_acl"
    Env  = "${var.env}"
  }
}

resource "aws_network_acl_rule" "allow_in_http_acl" {
  network_acl_id = aws_network_acl.demo1_public_sub_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "allow_in_https_acl" {
  network_acl_id = aws_network_acl.demo1_public_sub_acl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "allow_in_ssh_acl" {
  count          = length(local.admins_ips)
  network_acl_id = aws_network_acl.demo1_public_sub_acl.id
  rule_number    = 120 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.admins_ips[count.index]
  from_port      = 22
  to_port        = 22
}

# resource "aws_network_acl_rule" "allow_in_jenkins_acl" {
#   for_each       = toset(local.admins_ips)
#   network_acl_id = aws_network_acl.demo1_public_sub_acl.id
#   rule_number    = 130
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = each.value
#   from_port      = 8080
#   to_port        = 8080
# }

resource "aws_network_acl_rule" "allow_in_ephemeral_ports_acl" {
  network_acl_id = aws_network_acl.demo1_public_sub_acl.id
  rule_number    = 140
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "allow_in_db_acl" {
  network_acl_id = aws_network_acl.demo1_private_sub_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/23"
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "allow_out_pub_sub_acl" {
  network_acl_id = aws_network_acl.demo1_public_sub_acl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "allow_inner_out_pub_sub_acl" {
  network_acl_id = aws_network_acl.demo1_public_sub_acl.id
  rule_number    = 110
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "allow_out_db_acl" {
  network_acl_id = aws_network_acl.demo1_private_sub_acl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/23"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_association" "demo1_public_sub_acl_assoc" {
  for_each       = var.public_subnets
  network_acl_id = aws_network_acl.demo1_public_sub_acl.id
  subnet_id      = aws_subnet.demo1_public_subnet[each.key].id
}

resource "aws_network_acl_association" "demo1_private_sub_acl_assoc" {
  for_each       = var.private_subnets
  network_acl_id = aws_network_acl.demo1_private_sub_acl.id
  subnet_id      = aws_subnet.demo1_private_subnet[each.key].id
}

resource "aws_security_group" "demo1_app_server_sg" {
  name        = "demo1_app_server_sg"
  description = "Manage inbound and outbound traffic for the app servers"
  vpc_id      = aws_vpc.demo1.id

  tags = {
    Env = "${var.env}"
  }
}

# resource "aws_security_group" "demo1_cicd_server_sg" {
#   name        = "demo1_cicd_server_sg"
#   description = "Manage inbound and outbound traffic for the ci/cd servers"
#   vpc_id      = aws_vpc.demo1.id

#   tags = {
#     Env = "${var.env}"
#   }
# }

resource "aws_security_group" "demo1_db_server_sg" {
  name        = "demo1_db_server_sg"
  description = "Manage inbound and outbound traffic for the db servers"
  vpc_id      = aws_vpc.demo1.id

  tags = {
    Env = "${var.env}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_in_http_traffic" {
  security_group_id = aws_security_group.demo1_app_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Allow inbound HTTP from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_in_https_traffic" {
  security_group_id = aws_security_group.demo1_app_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow inbound HTTPS from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_in_ssh_traffic" {
  for_each          = local.sg_ip_pairs
  security_group_id = local.my_sgs[each.value.sg_key]
  cidr_ipv4         = each.value.ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "Allow inbound SSH from admins IPs"
}

# resource "aws_vpc_security_group_ingress_rule" "allow_in_http_jenkins_traffic" {
#   for_each          = toset(local.admins_ips)
#   security_group_id = aws_security_group.demo1_cicd_server_sg.id
#   cidr_ipv4         = each.value
#   from_port         = 8080
#   ip_protocol       = "tcp"
#   to_port           = 8080
#   description       = "Allow inbound HTTP from admins to access the jenkins dashboard"
# }

resource "aws_vpc_security_group_ingress_rule" "allow_in_db_traffic" {
  security_group_id            = aws_security_group.demo1_db_server_sg.id
  referenced_security_group_id = aws_security_group.demo1_app_server_sg.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
  description                  = "Allow inbound db traffic from app servers"
}

resource "aws_vpc_security_group_egress_rule" "allow_out_app_server_traffic" {
  security_group_id = aws_security_group.demo1_app_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "-1"
  to_port           = -1
  description       = "Allow outbound traffic to anywhere"
}

# resource "aws_vpc_security_group_egress_rule" "allow_out_cicd_server_traffic" {
#   security_group_id = aws_security_group.demo1_cicd_server_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = -1
#   ip_protocol       = "-1"
#   to_port           = -1
#   description       = "Allow outbound traffic to anywhere"
# }

resource "aws_vpc_security_group_egress_rule" "allow_out_db_traffic" {
  security_group_id            = aws_security_group.demo1_db_server_sg.id
  referenced_security_group_id = aws_security_group.demo1_app_server_sg.id
  from_port                    = 1024
  ip_protocol                  = "tcp"
  to_port                      = 65535
  description                  = "Allow outbound db traffic to app servers"
}

resource "aws_key_pair" "demo1_ec2_key" {
  key_name   = "demo1_ec2_key"
  public_key = file("~/.ssh/demo1Ec2Key.pub")
}

resource "aws_network_interface" "ec2_nic1_as1" {
  subnet_id       = values(aws_subnet.demo1_public_subnet)[0].id
  private_ips     = ["10.0.0.100"]
  security_groups = [aws_security_group.demo1_app_server_sg.id]

  tags = {
    Name = "ec2_nic1_as1"
  }
}

resource "aws_instance" "demo1_app_server1" {
  ami           = data.aws_ami.server_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.demo1_ec2_key.id
  #user_data     = file("userdata.tpl")

  network_interface {
    network_interface_id = aws_network_interface.ec2_nic1_as1.id
    device_index         = 0
  }

  tags = {
    Name = "demo1_app_server1"
    Env  = "${var.env}"
  }

  #provisioner -> you can use ansible instead
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip
      user         = "ubuntu"
      identityfile = "~/.ssh/demo1Ec2Key"
    })
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
  }
}

resource "aws_db_subnet_group" "demo1_db_subnet_group" {
  name       = "demo1_db_subnet_group"
  subnet_ids = values(aws_subnet.demo1_private_subnet).*.id

  tags = {
    Name = "postgres subnet group"
    Env  = "${var.env}"
  }
}

resource "aws_db_parameter_group" "demo1_db_parameter_group" {
  name   = "rds-pg-postgres-17"
  family = "postgres17"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = {
    Name = "postgres parameter group"
    Env  = "${var.env}"
  }
}

resource "aws_db_instance" "demo1_primary_db" {
  username                = var.db_creds.username
  password                = var.db_creds.password
  skip_final_snapshot     = true
  publicly_accessible     = false
  parameter_group_name    = aws_db_parameter_group.demo1_db_parameter_group.name
  instance_class          = var.db_instance_class
  engine                  = "postgres"
  engine_version          = "17.4"
  db_name                 = "demo1_db"
  db_subnet_group_name    = aws_db_subnet_group.demo1_db_subnet_group.name
  backup_retention_period = 1
  allocated_storage       = 15
  storage_type            = "gp2"
  multi_az                = false

  vpc_security_group_ids = [aws_security_group.demo1_db_server_sg.id]

  tags = {
    Name = "demo1_primary_db"
    Env  = "${var.env}"
  }
}

# resource "aws_db_instance" "demo1_read_replica_db" {
#   skip_final_snapshot     = true
#   replicate_source_db     = aws_db_instance.demo1_primary_db.identifier
#   publicly_accessible     = false
#   parameter_group_name    = aws_db_parameter_group.demo1_db_parameter_group.name
#   instance_class          = var.db_instance_class
#   identifier              = "demo1-read-replica-db"
#   backup_retention_period = 1
#   apply_immediately       = true

#   vpc_security_group_ids = [aws_security_group.demo1_db_server_sg.id]

#   tags = {
#     Replica = "true"
#     Name    = "demo1_read_replica_db"
#     Env     = "${var.env}"
#   }
# }


