variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "public_rules" {
  description = "List of objects for public NACL rules"
  type = list(object({
    rule_number = number
    egress      = bool
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
}

variable "private_rules" {
  description = "List of objects for private NACL rules"
  type = list(object({
    rule_number = number
    egress      = bool
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = number
    to_port     = number
  }))
}

variable "ssh_admin_ips" {
  description = "List of admin IPs for SSH NACL rules"
  type        = list(string)
  default     = []
}