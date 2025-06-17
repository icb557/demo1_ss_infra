module "vpc" {
  source               = "./modules/networking/vpc"
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  tags = {
    Name = "demo1"
    Env  = var.env
  }
}

module "nacls" {
  source             = "./modules/networking/nacl"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  tags = {
    Env = var.env
  }

  public_rules = [
    {
      rule_number = 100
      egress      = false
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
    },
    {
      rule_number = 110
      egress      = false
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 443
      to_port     = 443
    },
    {
      rule_number = 130
      egress      = false
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 8000
      to_port     = 8000
    },
    {
      rule_number = 140
      egress      = false
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 1024
      to_port     = 65535
    },
    {
      rule_number = 100
      egress      = true
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 65535
    },
    {
      rule_number = 110
      egress      = true
      protocol    = "-1"
      rule_action = "allow"
      cidr_block  = var.vpc_cidr
      from_port   = 0
      to_port     = 65535
    }
  ]

  private_rules = [
    {
      rule_number = 100
      egress      = false
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "10.0.0.0/23"
      from_port   = 5432
      to_port     = 5432
    },
    {
      rule_number = 100
      egress      = true
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = "10.0.0.0/23"
      from_port   = 1024
      to_port     = 65535
    }
  ]

  ssh_admin_ips = var.allowed_ips
}

module "security_groups" {
  source      = "./modules/networking/sg"
  vpc_id      = module.vpc.vpc_id
  env         = var.env
  allowed_ips = var.allowed_ips

  app_server_ingress_rules = concat([
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow inbound HTTP from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow inbound HTTPS from anywhere"
    },
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow inbound HTTPS from anywhere to the flask app"
    },
    ], [
    for ip in var.allowed_ips : {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ip]
      description = "Allow inbound SSH from admin IPs"
    }
  ])

  app_server_egress_rules = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow outbound traffic to anywhere"
    }
  ]

  db_server_ingress_rules = [
    {
      from_port                    = 5432
      to_port                      = 5432
      protocol                     = "tcp"
      cidr_blocks                  = []
      description                  = "Allow inbound db traffic from app servers"
      referenced_security_group_id = module.security_groups.app_server_sg_id
    }
  ]

  db_server_egress_rules = [
    {
      from_port                    = 1024
      to_port                      = 65535
      protocol                     = "tcp"
      cidr_blocks                  = []
      description                  = "Allow outbound db traffic to app servers"
      referenced_security_group_id = module.security_groups.app_server_sg_id
    }
  ]
}

module "vnic" {
  source             = "./modules/networking/vnic"
  subnet_id          = module.vpc.public_subnet_ids[0]
  private_ips        = ["10.0.0.100"]
  security_group_ids = [module.security_groups.app_server_sg_id]
}

module "app_server1" {
  source               = "./modules/compute/ec2"
  ami                  = data.aws_ami.server_ami.id
  instance_type        = "t2.micro"
  key_name             = "demo1_ec2_key"
  public_key           = file("~/.ssh/demo1Ec2Key.pub")
  network_interface_id = module.vnic.network_interface_id_as1
  tags = {
    Name = "demo1_app_server1"
    Env  = var.env
  }
  host_os       = var.host_os
  ssh_user      = "ubuntu"
  identity_file = "~/.ssh/demo1Ec2Key"

  db_user      = var.db_creds.username
  db_password  = var.db_creds.password
  db_host      = module.db_server1.db_instance_endpoint
  db_port      = module.db_server1.db_port
  db_name      = var.db_creds.db_name
  test_db_name = "test_db"
}

module "db_server1" {
  source                    = "./modules/database/rds"
  subnet_ids                = module.vpc.private_subnet_ids
  db_parameter_group_name   = "rds-pg-postgres-17"
  db_parameter_group_family = "postgres17"
  db_parameter_name         = "log_connections"
  db_parameter_value        = "1"
  db_instance_username      = var.db_creds.username
  db_instance_password      = var.db_creds.password
  db_instance_class         = var.db_instance_class
  db_engine                 = "postgres"
  db_engine_version         = "17.4"
  db_name                   = var.db_creds.db_name
  backup_retention_period   = 1
  allocated_storage         = 15
  storage_type              = "gp2"
  multi_az                  = false
  vpc_security_group_ids    = [module.security_groups.db_server_sg_id]
  tags = {
    Env = var.env
  }
}

data "infisical_secret" "db_password" {
  path = "DB_PASSWORD"
}

data "infisical_secret" "db_user" {
  path = "DB_USER"
}

data "infisical_secret" "db_password" {
  path = "DB_PASSWORD"
}
