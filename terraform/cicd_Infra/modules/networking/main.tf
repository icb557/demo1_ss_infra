resource "azurerm_virtual_network" "cicd_vnet" {
  name                = "cicd-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_address_space]

  tags = var.tags
}

resource "azurerm_subnet" "cicd_subnet" {
  name                 = "cicd-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.cicd_vnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_subnet" "grafana_subnet" {
  name                 = "grafana-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.cicd_vnet.name
  address_prefixes     = [var.grafana_subnet_prefix]
}

resource "azurerm_public_ip" "cicd_pip" {
  name                = "cicd-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                = "Standard"

  tags = var.tags
}

resource "azurerm_public_ip" "grafana_pip" {
  name                = "grafana-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                = "Standard"

  tags = var.tags
}

resource "azurerm_network_security_group" "cicd_nsg" {
  name                = "cicd-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.allowed_ips
    content {
      name                       = "allow-ssh-${replace(security_rule.value, "/", "-")}"
      priority                   = 120 + index(var.allowed_ips, security_rule.value)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.allowed_ips
    content {
      name                       = "allow-jenkins-${replace(security_rule.value, "/", "-")}"
      priority                   = 130 + index(var.allowed_ips, security_rule.value)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "grafana_nsg" {
  name                = "grafana-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  dynamic "security_rule" {
    for_each = var.allowed_ips
    content {
      name                       = "allow-ssh-${replace(security_rule.value, "/", "-")}"
      priority                   = 120 + index(var.allowed_ips, security_rule.value)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = var.allowed_ips
    content {
      name                       = "allow-grafana-${replace(security_rule.value, "/", "-")}"
      priority                   = 130 + index(var.allowed_ips, security_rule.value)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3000"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "cicd_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.cicd_subnet.id
  network_security_group_id = azurerm_network_security_group.cicd_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "grafana_nsg_association" {
  subnet_id                 = azurerm_subnet.grafana_subnet.id
  network_security_group_id = azurerm_network_security_group.grafana_nsg.id
} 