pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_CLI_ARGS = '-no-color'
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['validate', 'plan', 'apply'],
            description: 'Terraform action'
        )
        choice(
            name: 'ENVIRONMENT', 
            choices: ['dev', 'staging', 'prod'],
            description: 'Environment'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "✅ Código descargado"
            }
        }
        
        stage('Terraform Version') {
            steps {
                sh 'terraform --version'
                sh 'aws --version'
            }
        }
        
        stage('Terraform Init') {
            steps {
                withAWS(credentials: 'aws-credentials', region: env.AWS_DEFAULT_REGION) {
                    dir('terraform') {
                        sh """
                            echo "🔧 Inicializando Terraform..."
                            terraform init -backend-config="key=${params.ENVIRONMENT}/terraform.tfstate"
                        """
                    }
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh '''
                        echo "✅ Validando configuración..."
                        terraform validate
                        terraform fmt -check=true
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            when {
                anyOf {
                    expression { params.ACTION == 'plan' }
                    expression { params.ACTION == 'apply' }
                }
            }
            steps {
                withAWS(credentials: 'aws-credentials', region: env.AWS_DEFAULT_REGION) {
                    dir('terraform') {
                        sh """
                            echo "📋 Generando plan para ${params.ENVIRONMENT}..."
                            terraform plan -var-file="environments/${params.ENVIRONMENT}.tfvars" -out=tfplan
                            terraform show -no-color tfplan > plan.txt
                        """
                        
                        archiveArtifacts artifacts: 'plan.txt'
                    }
                }
            }
        }
        
        stage('Approval') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    def planOutput = readFile('terraform/plan.txt')
                    def planSummary = planOutput.split('\n').findAll { 
                        it.contains('Plan:') || it.contains('No changes')
                    }.join('\n')
                    
                    input message: "¿Aplicar cambios?\n\n${planSummary}", ok: 'Apply!'
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withAWS(credentials: 'aws-credentials', region: env.AWS_DEFAULT_REGION) {
                    dir('terraform') {
                        sh '''
                            echo "🚀 Aplicando cambios..."
                            terraform apply tfplan
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            dir('terraform') {
                sh 'rm -f tfplan plan.txt || true'
            }
        }
        success {
            echo "✅ Pipeline completado exitosamente"
        }
        failure {
            echo "❌ Pipeline falló"
        }
    }
}