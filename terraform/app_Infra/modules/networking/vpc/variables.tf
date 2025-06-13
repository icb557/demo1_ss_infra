variable "cidr_block" {
  type = string
}

variable "enable_dns_hostnames" {
  type = bool
  default = true
}

variable "enable_dns_support" {
  type = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "public_subnets" {
  description = "Map of public subnets configurations"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  description = "Map of private subnets configurations"
  type = map(object({
    cidr = string
    az   = string
  }))
} 