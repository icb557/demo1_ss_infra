host_os     = "linux"
env         = "dev"
vpc_cidr    = "10.0.0.0/16"
allowed_ips = ["181.71.139.122/32", "3.89.142.113/32", "38.156.230.172/32"]

public_subnets = {
  public_subnet1 = {
    cidr = "10.0.0.0/24"
    az   = "us-east-1a"
  }
  public_subnet2 = {
    cidr = "10.0.1.0/24"
    az   = "us-east-1b"
  }
}

private_subnets = {
  private_subnet1 = {
    cidr = "10.0.2.0/24"
    az   = "us-east-1a"
  }
  private_subnet2 = {
    cidr = "10.0.3.0/24"
    az   = "us-east-1b"
  }
}

db_creds = {
  db_name  = "demo1_db"
  username = "devops"
  password = "devops123"
}

