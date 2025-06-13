variable "subnet_ids" {
  type = list(string)
}

variable "db_parameter_group_name" {
  type = string
  default = "rds-pg-postgres-17"
}

variable "db_parameter_group_family" {
  type = string
  default = "postgres17"
}

variable "db_parameter_name" {
  type = string
  default = "log_connections"
}

variable "db_parameter_value" {
  type = string
  default = "1"
}

variable "db_instance_username" {
  type = string
}

variable "db_instance_password" {
  type = string
  sensitive = true
}

variable "db_instance_class" {
  type = string
}

variable "db_engine" {
  type = string
  default = "postgres"
}

variable "db_engine_version" {
  type = string
  default = "17.4"
}

variable "db_name" {
  type = string
  default = "demo1_db"
}

variable "backup_retention_period" {
  type = number
  default = 1
}

variable "allocated_storage" {
  type = number
  default = 15
}

variable "storage_type" {
  type = string
  default = "gp2"
}

variable "multi_az" {
  type = bool
  default = false
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
  default = {}
} 