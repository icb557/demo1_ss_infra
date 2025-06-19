output "vm_id" {
  description = "ID of the Jenkins VM"
  value       = azurerm_linux_virtual_machine.jenkins_vm.id
}

output "vm_private_ip" {
  description = "Private IP address of the Jenkins VM"
  value       = azurerm_network_interface.jenkins_nic.private_ip_address
}

output "vm_public_ip" {
  description = "Public IP address of the Jenkins VM"
  value       = azurerm_linux_virtual_machine.jenkins_vm.public_ip_address
}

output "data_disk_id" {
  description = "ID of the attached data disk"
  value       = azurerm_managed_disk.jenkins_disk.id
}

output "grafana_public_ip" {
  description = "Public IP address of the Grafana VM"
  value       = azurerm_linux_virtual_machine.grafana_vm.public_ip_address
} 