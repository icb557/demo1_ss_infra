variable "host_os" {
  description = "Host OS"
  type        = string
}

variable "name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the launch template name"
  type        = string
}

variable "ami" {
  description = "AMI ID for the instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the instances"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the instances"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs to associate with the ASG"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 1
} 

variable "db_host" {
  description = "DB host"
  type        = string
  default     = ""
}

variable "db_user" {
  description = "DB user"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "DB password"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "DB name"
  type        = string
  default     = ""
}