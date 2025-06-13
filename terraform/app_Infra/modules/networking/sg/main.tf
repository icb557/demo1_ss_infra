resource "aws_security_group" "app_server_sg" {
  name        = "app_server_sg"
  description = "App server security group"
  vpc_id      = var.vpc_id

  tags = {
    Env = var.env
    Name = "app_server_sg"
  }
}

resource "aws_security_group" "db_server_sg" {
  name        = "db_server_sg"
  description = "DB server security group"
  vpc_id      = var.vpc_id

  tags = {
    Env = var.env
    Name = "db_server_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_server_ingress" {
  for_each = { for idx, rule in var.app_server_ingress_rules : idx => rule }
  security_group_id = aws_security_group.app_server_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  description       = each.value.description
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)
}

resource "aws_vpc_security_group_egress_rule" "app_server_egress" {
  for_each = { for idx, rule in var.app_server_egress_rules : idx => rule }
  security_group_id = aws_security_group.app_server_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  description       = each.value.description
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)
}

resource "aws_vpc_security_group_ingress_rule" "db_server_ingress" {
  for_each = { for idx, rule in var.db_server_ingress_rules : idx => rule }
  security_group_id = aws_security_group.db_server_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  description       = each.value.description
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)
}

resource "aws_vpc_security_group_egress_rule" "db_server_egress" {
  for_each = { for idx, rule in var.db_server_egress_rules : idx => rule }
  security_group_id = aws_security_group.db_server_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  description       = each.value.description
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)
}