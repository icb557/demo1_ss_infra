# ========================================
# OUTPUTS PARA TERRAFORM/JENKINS
# ========================================

# Output del Access Key ID para Terraform/Jenkins
output "terraform_access_key_id" {
  value     = aws_iam_access_key.terraform_key.id
  sensitive = false
  description = "Access Key ID for Terraform/Jenkins user"
}

# Output del Secret Access Key para Terraform/Jenkins (sensible)
output "terraform_secret_access_key" {
  value     = aws_iam_access_key.terraform_key.secret
  sensitive = true
  description = "Secret Access Key for Terraform/Jenkins user (sensitive)"
}

# Output del nombre del usuario de Terraform/Jenkins
output "terraform_username" {
  value       = aws_iam_user.terraform_user.name
  description = "Username for Terraform/Jenkins"
}

# Output del ARN de la política de Terraform
output "terraform_policy_arn" {
  value       = aws_iam_policy.terraform_policy.arn
  description = "ARN of the Terraform/Jenkins policy"
}

# ========================================
# OUTPUTS PARA GRAFANA
# ========================================

# Output del Access Key ID para Grafana
output "grafana_access_key_id" {
  value     = aws_iam_access_key.grafana_key.id
  sensitive = false
  description = "Access Key ID for Grafana user"
}

# Output del Secret Access Key para Grafana (sensible)
output "grafana_secret_access_key" {
  value     = aws_iam_access_key.grafana_key.secret
  sensitive = true
  description = "Secret Access Key for Grafana user (sensitive)"
}

# Output del nombre del usuario de Grafana
output "grafana_username" {
  value       = aws_iam_user.grafana_user.name
  description = "Username for Grafana"
}

# Output del ARN de la política de Grafana
output "grafana_policy_arn" {
  value       = aws_iam_policy.grafana_policy.arn
  description = "ARN of the Grafana monitoring policy"
}

# ========================================
# OUTPUTS GENERALES
# ========================================

# Output con información de ambos usuarios
output "users_info" {
  value = {
    terraform = {
      username = aws_iam_user.terraform_user.name
      policy   = aws_iam_policy.terraform_policy.name
      purpose  = "Infrastructure management"
    }
    grafana = {
      username = aws_iam_user.grafana_user.name
      policy   = aws_iam_policy.grafana_policy.name
      purpose  = "Monitoring and visualization"
    }
  }
  description = "Information about both IAM users and their purposes"
} 