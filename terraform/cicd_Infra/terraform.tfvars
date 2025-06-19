host_os                = "windows"
env                    = "dev"
resource_group_name    = "cicd-rg"
vnet_address_space     = "10.0.0.0/16"
allowed_ips            = ["181.71.139.122/32", "3.89.142.113/32", "38.156.230.172/32", "181.50.20.145/32", "191.91.80.101/32"]
subnet_address_prefix  = "10.0.1.0/24"
jenkins_admin_password = "admin"
tags = {
  Environment = "cicd"
  Project     = "jenkins"
}