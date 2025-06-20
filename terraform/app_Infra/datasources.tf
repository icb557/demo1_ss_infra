data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "infisical_secrets" "db_creds" {
  env_slug     = "dev"
  workspace_id = var.infisical_project_id
  folder_path  = "/"
}