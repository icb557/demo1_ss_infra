pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        TF_CLI_ARGS = '-no-color'
        GITHUB_TOKEN = credentials('github-token')
        REPO_OWNER = 'icb557'
        REPO_NAME = 'demo1_ss_infra'
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['validate', 'plan', 'apply', 'destroy', 'playbook'],
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
            sh """git clone https://github.com/${REPO_OWNER}/${REPO_NAME}"""
            echo "✅ Code downloaded"
            sh """ls -al"""

            // script {
            //     env.FORCED_ACTION = 'playbook'  // Assign 'playbook' to a new environment variable
            //     echo "Forced ACTION to: ${env.FORCED_ACTION}"  // For debugging
            // }
        }
    }
    
    stage('Terraform Init') {
        steps {                
            dir('demo1_ss_infra/terraform/app_Infra') {
                sh """
                    echo "🔧 Initializing Terraform..."
                    terraform init
                """
            }
        }
    }
    
    stage('Terraform Plan') {
        when {
            anyOf {
                expression { params.ACTION == 'plan' }
                expression { params.ACTION == 'apply' }
                expression { env.IS_PR == 'true' }
            }
        }
        steps {
            
            dir('demo1_ss_infra/terraform/app_Infra') {
                sh """
                    echo "📋 Generating plan for ${params.ENVIRONMENT}..."
                    terraform plan -out=tfplan
                    terraform show -no-color tfplan > plan.txt
                """
                
                archiveArtifacts artifacts: 'plan.txt'
            }
        }
    }
    
    stage('Terraform Apply') {
        when {
            expression { params.ACTION == 'apply' }
        }
        steps {
            
            dir('demo1_ss_infra/terraform/app_Infra') {
                sh '''
                    echo "🚀 Applying changes..."
                    terraform apply tfplan
                '''            
            }
        }
    }
    
    stage('Terraform Destroy') {
        when {
            expression { params.ACTION == 'destroy' }
        }
        steps {
            dir('demo1_ss_infra/terraform/app_Infra') {
                sh 'terraform destroy -auto-approve'
            }
        }
    }
    
    stage('Run Ansible Playbook') {
        when {
            expression { params.ACTION == 'apply' || params.ACTION == 'playbook' }
            //expression { env.FORCED_ACTION == 'playbook' }
        }
        steps {
            dir('demo1_ss_infra') {     
                // script {
                //     def appServerIp = readFile('/var/jenkins_home/app_server_ip.txt').trim()
                //     env.APP_SERVER_IP = appServerIp
                // }
                sh """
                    ansible-playbook \\
                        -i terraform/app_Infra/hosts.ini \\
                        ansible/playbooks/infra_playbook.yml \\
                        --ssh-common-args='-o StrictHostKeyChecking=no'
                """
            }
        }
    }

    // stage('Copy hosts file to shared path'){
    //     when {
    //         expression { params.ACTION == 'apply' || params.ACTION == 'playbook' }
    //         //expression { env.FORCED_ACTION == 'playbook' }
    //     }
    //     steps {
    //         dir('demo1_ss_infra/terraform/app_Infra') {
    //             sh 'cp ansible/inventories/hosts.ini /var/jenkins_home/shared/hosts.ini'
    //         }
    //     }
    // }
    }
    
    post {
        always {
            dir('demo1_ss_infra/terraform/app_Infra') {
                sh 'rm -f tfplan plan.txt || true'
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