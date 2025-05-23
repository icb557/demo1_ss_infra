host_os  = "windows"
env      = "dev"
vpc_cidr = "10.0.0.0/16"

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
  username = "devops"
  password = "devops123"
}

