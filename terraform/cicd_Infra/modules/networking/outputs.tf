output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.cicd_vnet.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.cicd_subnet.id
}

output "grafana_subnet_id" {
  description = "ID of the Grafana subnet"
  value       = azurerm_subnet.grafana_subnet.id
}

output "public_ip_id" {
  description = "ID of the public IP"
  value       = azurerm_public_ip.cicd_pip.id
}

output "grafana_public_ip" {
  description = "Public IP address of the Grafana VM"
  value       = azurerm_public_ip.grafana_pip.ip_address
}

output "public_ip_address" {
  description = "Public IP address"
  value       = azurerm_public_ip.cicd_pip.ip_address
}
output "grafana_public_ip_id" {
  description = "ID of the Grafana public IP"
  value       = azurerm_public_ip.grafana_pip.id
}

output "nsg_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.cicd_nsg.id
} 