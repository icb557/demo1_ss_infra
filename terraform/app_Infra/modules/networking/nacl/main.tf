resource "aws_network_acl" "public_nacl" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "demo1_public_sub_acl" })
}

resource "aws_network_acl" "private_nacl" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "demo1_private_sub_acl" })
}

# Public NACL rules
resource "aws_network_acl_rule" "public_rules" {
  for_each       = { for rule in var.public_rules : "${rule.rule_number}-${rule.egress}" => rule }
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# Private NACL rules
resource "aws_network_acl_rule" "private_rules" {
  for_each       = { for rule in var.private_rules : "${rule.rule_number}-${rule.egress}" => rule }
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "allow_in_ssh_acl" {
  count          = length(var.ssh_admin_ips)
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 120 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.ssh_admin_ips[count.index]
  from_port      = 22
  to_port        = 22
}

# Associations
resource "aws_network_acl_association" "public_assoc" {
  count          = length(var.public_subnet_ids)
  network_acl_id = aws_network_acl.public_nacl.id
  subnet_id      = var.public_subnet_ids[count.index]
}

resource "aws_network_acl_association" "private_assoc" {
  count          = length(var.private_subnet_ids)
  network_acl_id = aws_network_acl.private_nacl.id
  subnet_id      = var.private_subnet_ids[count.index]
}