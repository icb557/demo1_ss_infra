resource "azurerm_resource_group" "cicd" {
  name     = "cicd-rg"
  location = var.location

  tags = var.tags
}

module "networking" {
  source = "./modules/networking"

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_address_space  = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix
  grafana_subnet_prefix = var.grafana_subnet_prefix
  allowed_ips         = var.allowed_ips
  tags                = var.tags
}

module "compute" {
  source = "./modules/compute"

  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id              = module.networking.subnet_id
  grafana_subnet_id   = module.networking.grafana_subnet_id
  public_ip_id           = module.networking.public_ip_id
  grafana_public_ip_id = module.networking.grafana_public_ip_id
  jenkins_admin_password = var.jenkins_admin_password
  tags                = var.tags
}