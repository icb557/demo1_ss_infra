output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins server"
  value       = module.compute.vm_public_ip
}

output "jenkins_private_ip" {
  description = "Private IP address of the Jenkins server"
  value       = module.compute.vm_private_ip
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.cicd.name
}