variable "subnet_id" {
  type = string
}

variable "private_ips" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}