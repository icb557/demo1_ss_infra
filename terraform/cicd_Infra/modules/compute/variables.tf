variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the VM will be created"
  type        = string
}

variable "grafana_subnet_id" {
  description = "ID of the Grafana subnet"
  type        = string
}

variable "public_ip_id" {
  description = "ID of the public IP to associate with the VM"
  type        = string
}

variable "grafana_public_ip_id" {
  description = "ID of the Grafana public IP"
  type        = string
}

variable "jenkins_admin_password" {
  description = "Password for the Jenkins admin user"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
} 