# ========================================
# POLÍTICA PARA TERRAFORM/JENKINS
# ========================================

# Crear la política para Terraform/Jenkins
resource "aws_iam_policy" "terraform_policy" {
  name        = "TerraformJenkinsPolicy"
  description = "Policy for Terraform and Jenkins to manage infrastructure"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "rds:*",
          "iam:GetRole",
          "iam:ListRoles",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "cloudwatch:*",
          "autoscaling:*",
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ========================================
# POLÍTICA PARA GRAFANA (Oficial AWS)
# ========================================

# Crear la política para Grafana usando la política oficial recomendada por AWS
resource "aws_iam_policy" "grafana_policy" {
  name        = "GrafanaMonitoringPolicy"
  description = "Official AWS recommended policy for Grafana monitoring and visualization"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowReadingMetricsFromCloudWatch"
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetInsightRuleReport"
        ]
        Resource = "*"
      },
      {
        Sid = "AllowReadingResourceMetricsFromPerformanceInsights"
        Effect = "Allow"
        Action = "pi:GetResourceMetrics"
        Resource = "*"
      },
      {
        Sid = "AllowReadingLogsFromCloudWatch"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid = "AllowReadingTagsInstancesRegionsFromEC2"
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      },
      {
        Sid = "AllowReadingResourcesForTags"
        Effect = "Allow"
        Action = "tag:GetResources"
        Resource = "*"
      }
    ]
  })
}

# ========================================
# USUARIOS IAM
# ========================================

# Usuario para Terraform/Jenkins
resource "aws_iam_user" "terraform_user" {
  name = "terraform-jenkins-user"
  
  tags = {
    Name = "terraform-jenkins-user"
    Purpose = "Terraform and Jenkins automation"
    Environment = "dev"
  }
}

# Usuario para Grafana
resource "aws_iam_user" "grafana_user" {
  name = "grafana-monitoring-user"
  
  tags = {
    Name = "grafana-monitoring-user"
    Purpose = "Grafana monitoring and visualization"
    Environment = "dev"
  }
}

# ========================================
# ASIGNACIÓN DE POLÍTICAS
# ========================================

# Asignar política de Terraform al usuario de Terraform
resource "aws_iam_user_policy_attachment" "terraform_policy_attachment" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}

# Asignar política de Grafana al usuario de Grafana
resource "aws_iam_user_policy_attachment" "grafana_policy_attachment" {
  user       = aws_iam_user.grafana_user.name
  policy_arn = aws_iam_policy.grafana_policy.arn
}

# ========================================
# ACCESS KEYS
# ========================================

# Access key para Terraform/Jenkins
resource "aws_iam_access_key" "terraform_key" {
  user = aws_iam_user.terraform_user.name
}

# Access key para Grafana
resource "aws_iam_access_key" "grafana_key" {
  user = aws_iam_user.grafana_user.name
} 