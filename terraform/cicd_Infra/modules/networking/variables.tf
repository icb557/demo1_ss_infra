variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
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
  description = "List of IP addresses allowed to access SSH and Jenkins"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
} 