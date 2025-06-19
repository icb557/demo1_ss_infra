resource "azurerm_network_interface" "jenkins_nic" {
  name                = "jenkins-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

resource "azurerm_network_interface" "grafana_nic" {
  name                = "grafana-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.grafana_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.grafana_public_ip_id
  }
}

resource "azurerm_linux_virtual_machine" "jenkins_vm" {
  name                = "jenkins-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.jenkins_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/cicdVmKey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server-gen1"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yml", {
    jenkins_admin_password = var.jenkins_admin_password
  }))

  tags = var.tags

  # provisioner "local-exec" {
  #   command = <<-EOT
  #     ssh-keygen -R ${self.public_ip_address} || true
  #     ssh-keyscan -H ${self.public_ip_address} >> ~/.ssh/known_hosts
  #   EOT
  #   interpreter = ["PowerShell", "-Command"]
  # }
}

resource "azurerm_linux_virtual_machine" "grafana_vm" {
  name                = "grafana-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.grafana_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/grafanaVmKey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server-gen1"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/grafana-cloud-init.yml"))

  tags = var.tags

  # provisioner "local-exec" {
  #   command = <<-EOT
  #     ssh-keygen -R ${self.public_ip_address} || true
  #     ssh-keyscan -H ${self.public_ip_address} >> ~/.ssh/known_hosts
  #   EOT
  #   interpreter = ["PowerShell", "-Command"]
  # }
}

resource "azurerm_managed_disk" "jenkins_disk" {
  name                 = "jenkins-disk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 16

  tags = var.tags
}

resource "azurerm_managed_disk" "grafana_disk" {
  name                 = "grafana-disk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "jenkins_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.jenkins_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.jenkins_vm.id
  lun                = 0
  caching            = "ReadWrite"
} 

resource "azurerm_virtual_machine_data_disk_attachment" "grafana_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.grafana_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.grafana_vm.id
  lun                = 0
  caching            = "ReadWrite"
} 