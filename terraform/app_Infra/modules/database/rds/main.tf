resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "demo1_db_subnet_group"
  subnet_ids = var.subnet_ids

  tags = merge({
    Name = "postgres subnet group"
  }, var.tags)
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = var.db_parameter_group_name
  family = var.db_parameter_group_family

  parameter {
    name  = var.db_parameter_name
    value = var.db_parameter_value
  }

  tags = merge({
    Name = "postgres parameter group"
  }, var.tags)
}

resource "aws_db_instance" "primary_db" {
  username                = var.db_instance_username
  password                = var.db_instance_password
  skip_final_snapshot     = true
  publicly_accessible     = false
  parameter_group_name    = aws_db_parameter_group.db_parameter_group.name
  instance_class          = var.db_instance_class
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  db_name                 = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  backup_retention_period = var.backup_retention_period
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  multi_az                = var.multi_az
  vpc_security_group_ids  = var.vpc_security_group_ids

  tags = merge({
    Name = "demo1_primary_db"
  }, var.tags)
}