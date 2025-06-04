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
    Name = "cicd_${var.public_subnets.public_subnet1.key}"
    Env  = "${var.env}"
  }
}