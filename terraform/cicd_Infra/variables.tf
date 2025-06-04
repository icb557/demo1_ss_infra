variable "host_os" {
  type    = string
  default = "linux"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "allowed_ips" {
  type    = list(string)
  default = ["181.71.139.122/32"]
}

variable "vpc_cidr" {
  type    = string
  default = "20.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets configurations"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    public_subnet1 = {
      cidr = "20.0.0.0/24"
      az   = "us-east-1a"
    }
    public_subnet2 = {
      cidr = "20.0.1.0/24"
      az   = "us-east-1b"
    }
  }
}

variable "private_subnets" {
  description = "Map of private subnets configurations"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    private_subnet1 = {
      cidr = "20.0.2.0/24"
      az   = "us-east-1a"
    }
    private_subnet2 = {
      cidr = "20.0.3.0/24"
      az   = "us-east-1b"
    }
  }
}


