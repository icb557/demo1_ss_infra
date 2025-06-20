variable "host_os" {
  type    = string
  default = "windows"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "allowed_ips" {
  type    = list(string)
  default = ["181.71.139.122/32", "3.89.142.113/32", "38.156.230.172/32"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets configurations"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    public_subnet1 = {
      cidr = "10.0.0.0/24"
      az   = "us-east-1a"
    }
    public_subnet2 = {
      cidr = "10.0.1.0/24"
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
      cidr = "10.0.2.0/24"
      az   = "us-east-1a"
    }
    private_subnet2 = {
      cidr = "10.0.3.0/24"
      az   = "us-east-1b"
    }
  }
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "infisical_token" {
  description = "Infisical personal access token"
  type        = string
}

variable "infisical_project_id" {
  description = "Infisical project id"
  type        = string
}