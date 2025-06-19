# IAM Infrastructure for Terraform/Jenkins and Grafana

Este directorio contiene la configuración de Terraform para crear los recursos IAM necesarios para que Terraform, Jenkins y Grafana puedan gestionar y monitorear la infraestructura AWS.

## Recursos creados

### 🔧 Terraform/Jenkins
- **Política IAM**: `TerraformJenkinsPolicy` con permisos para gestión de infraestructura
- **Usuario IAM**: `terraform-jenkins-user` 
- **Access Key**: Credenciales para autenticación programática

### 📊 Grafana
- **Política IAM**: `GrafanaMonitoringPolicy` con permisos oficiales recomendados por AWS
- **Usuario IAM**: `grafana-monitoring-user`
- **Access Key**: Credenciales para acceso a métricas y logs

## Cómo usar

### 1. Inicializar Terraform
```bash
cd terraform/iam_infra
terraform init
```

### 2. Ver el plan
```bash
terraform plan
```

### 3. Aplicar los cambios
```bash
terraform apply
```

### 4. Obtener las credenciales

#### Para Terraform/Jenkins:
```bash
# Access Key ID
terraform output terraform_access_key_id

# Secret Access Key (sensible)
terraform output terraform_secret_access_key
```

#### Para Grafana:
```bash
# Access Key ID
terraform output grafana_access_key_id

# Secret Access Key (sensible)
terraform output grafana_secret_access_key
```

## Permisos incluidos

### 🔧 Política de Terraform/Jenkins
Permisos para gestión de infraestructura:
- **EC2**: Gestión completa de instancias, VPC, subredes, etc.
- **RDS**: Gestión de bases de datos
- **S3**: Acceso al bucket de estado remoto
- **IAM**: Solo lectura de roles (GetRole, ListRoles)
- **CloudWatch**: Monitoreo
- **Auto Scaling**: Escalado automático
- **ELB**: Load balancers

### 📊 Política de Grafana (Oficial AWS)
Permisos organizados por funcionalidad:

#### **CloudWatch Metrics:**
- `cloudwatch:DescribeAlarmsForMetric`
- `cloudwatch:DescribeAlarmHistory`
- `cloudwatch:DescribeAlarms`
- `cloudwatch:ListMetrics`
- `cloudwatch:GetMetricData`
- `cloudwatch:GetInsightRuleReport`

#### **Performance Insights:**
- `pi:GetResourceMetrics`

#### **CloudWatch Logs:**
- `logs:DescribeLogGroups`
- `logs:GetLogGroupFields`
- `logs:StartQuery`
- `logs:StopQuery`
- `logs:GetQueryResults`
- `logs:GetLogEvents`

#### **EC2 Information:**
- `ec2:DescribeTags`
- `ec2:DescribeInstances`
- `ec2:DescribeRegions`

#### **Resource Tagging:**
- `tag:GetResources`

## Configuración en Jenkins

### Para Terraform/Jenkins:
1. Ve a **Manage Jenkins** → **Manage Credentials**
2. **System** → **Global credentials** → **Add Credentials**
3. Tipo: **AWS Credentials**
4. ID: `aws-credentials`
5. Access Key ID: (del output `terraform_access_key_id`)
6. Secret Access Key: (del output `terraform_secret_access_key`)

### Para Grafana:
1. Ve a **Manage Jenkins** → **Manage Credentials**
2. **System** → **Global credentials** → **Add Credentials**
3. Tipo: **AWS Credentials**
4. ID: `grafana-aws-credentials`
5. Access Key ID: (del output `grafana_access_key_id`)
6. Secret Access Key: (del output `grafana_secret_access_key`)

## Configuración en Grafana

### Configurar datasource de CloudWatch:
1. En Grafana, ve a **Configuration** → **Data Sources**
2. Agrega **CloudWatch** como nuevo datasource
3. Configura las credenciales AWS de Grafana
4. Testea la conexión

## Ventajas de políticas separadas

✅ **Principio de mínimos privilegios** - Cada usuario tiene solo los permisos necesarios  
✅ **Seguridad mejorada** - Separación clara de responsabilidades  
✅ **Auditoría más fácil** - Fácil rastrear qué usuario hizo qué  
✅ **Escalabilidad** - Fácil agregar más políticas específicas  
✅ **Mantenimiento** - Cambios en una política no afectan a la otra  
✅ **Política oficial** - Grafana usa la política recomendada por AWS  

## Notas importantes

- Los Secret Access Keys se marcan como sensibles y no se muestran en los logs
- Los recursos se crean con tags para mejor organización
- Cada política sigue el principio de mínimos privilegios
- La política de Grafana es la oficial recomendada por AWS
- Se pueden agregar más políticas específicas según necesidades futuras 