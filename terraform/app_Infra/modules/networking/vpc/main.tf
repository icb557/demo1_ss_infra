resource "aws_vpc" "demo1" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = var.tags
}

resource "aws_subnet" "public_subnet" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.demo1.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "demo1_${each.key}" })
}

resource "aws_subnet" "private_subnet" {
  for_each                = var.private_subnets
  vpc_id                  = aws_vpc.demo1.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "demo1_${each.key}" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo1.id
  tags = merge(var.tags, { Name = "demo1_igw" })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.demo1.id
  tags = merge(var.tags, { Name = "demo1_public_subnets__rt" })
}

resource "aws_route_table" "private_rt" {
  for_each = var.private_subnets
  vpc_id   = aws_vpc.demo1.id
  tags = merge(var.tags, { Name = "demo1_${each.key}_rt" })
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each       = var.private_subnets
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_rt[each.key].id
} 