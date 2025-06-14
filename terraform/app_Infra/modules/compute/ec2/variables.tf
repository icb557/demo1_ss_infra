variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "public_key" {
  type = string
}

variable "network_interface_id" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "host_os" {
  type = string
}

variable "ssh_user" {
  type = string
  default = "ubuntu"
}

variable "identity_file" {
  type = string
  default = "~/.ssh/demo1Ec2Key"
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "test_db_name" {
  description = "Test database name"
  type        = string
  default     = "test_db"
}