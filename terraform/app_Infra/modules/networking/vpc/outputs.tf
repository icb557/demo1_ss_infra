output "vpc_id" {
  value = aws_vpc.demo1.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public_subnet : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private_subnet : s.id]
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "private_route_table_ids" {
  value = { for k, rt in aws_route_table.private_rt : k => rt.id }
} 