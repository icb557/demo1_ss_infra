    pipeline {
        agent any

        environment {
            AWS_DEFAULT_REGION = 'us-east-1'
            TF_CLI_ARGS = '-no-color'
            GITHUB_TOKEN = credentials('github-token')
            REPO_OWNER = 'icb557'
            REPO_NAME = 'demo1_ss_infra'
        }
        
        parameters {
            choice(
                name: 'ACTION',
                choices: ['validate', 'plan', 'apply', 'destroy'],
                description: 'Terraform action for testing'
            )
            choice(
                name: 'ENVIRONMENT',
                choices: ['dev', 'staging', 'prod'],
                description: 'Environment for testing'
            )
            booleanParam(
                name: 'SKIP_APPROVAL',
                defaultValue: false,
                description: 'Skip any input approvals for testing'
            )
        }
        
        stages {
            stage('Checkout') {
                steps {
                    deleteDir()
                    sh """git clone -b FAD-15-task https://github.com/${REPO_OWNER}/${REPO_NAME}"""
                    echo '✅ Code downloaded for testing'
                    sh """ls -al demo1_ss_infra"""
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
                    dir('demo1_ss_infra/terraform') {
                        sh '''
                            echo "🔧 Initializing Terraform for testing..."
                            terraform init -backend-config="key=terraform.tfstate"
                        '''
                    }
                }
            }
            
            stage('Terraform Validate') {
                when {
                    expression { params.ACTION == 'validate' }
                }
                steps {
                    dir('demo1_ss_infra/terraform') {
                        sh '''
                            echo "✅ Validating configuration for testing..."
                            terraform validate
                            terraform fmt -check=true
                        '''
                    }
                }
            }
            
            stage('Terraform Plan') {
                when {
                    expression { params.ACTION == 'plan' }
                }
                steps {
                    dir('demo1_ss_infra/terraform') {
                        sh '''
                            echo "📋 Generating plan for testing..."
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
            
            stage('Terraform Apply') {
                when {
                    expression { params.ACTION == 'apply' }
                }
                steps {
                    dir('demo1_ss_infra/terraform') {
                        sh '''
                            echo "🚀 Applying changes for testing..."
                            terraform apply -auto-approve tfplan
                        '''
                    }
                }
            }
            
            stage('Terraform Destroy') {
                when {
                    expression { params.ACTION == 'destroy' }
                }
                steps {
                    dir('demo1_ss_infra/terraform') {
                        sh '''
                            echo "🧹 Destroying resources for testing..."
                            terraform destroy -auto-approve
                        '''
                    }
                }
            }
        }
        
        post {
            always {
                dir('demo1_ss_infra/terraform') {
                    sh 'rm -f tfplan || true'
                }
            }
            success {
                echo '✅ Testing pipeline completed successfully'
            }
            failure {
                echo '❌ Testing pipeline failed'
            }
        }
    }