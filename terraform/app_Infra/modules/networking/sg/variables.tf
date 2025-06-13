variable "vpc_id" {
  type = string
}

variable "env" {
  type = string
}

variable "allowed_ips" {
  type = list(string)
}

variable "app_server_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
    referenced_security_group_id = optional(string)
  }))
  default = []
}

variable "app_server_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
    referenced_security_group_id = optional(string)
  }))
  default = []
}

variable "db_server_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
    referenced_security_group_id = optional(string)
  }))
  default = []
}

variable "db_server_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
    referenced_security_group_id = optional(string)
  }))
  default = []
} 