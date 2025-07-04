variable "host_os" {
  type    = string
  default = "linux"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "grafana_subnet_prefix" {
  description = "Address prefix for the Grafana subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the VMs"
  type        = list(string)
}

variable "jenkins_admin_password" {
  description = "Password for the Jenkins admin user"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "cicd"
    Project     = "jenkins"
  }
}


