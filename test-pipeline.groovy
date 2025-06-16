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
        INFISICAL_TOKEN = credentials('infisical-token-id')
        INFISICAL_PROJECT_ID = credentials('infisical-project-id')
        ANSIBLE_CONFIG = "${WORKSPACE}/ansible.cfg"
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
        // stage('Checkout') {
        //     steps {
        //         deleteDir()
        //         sh """git clone https://github.com/${REPO_OWNER}/${REPO_NAME}"""
        //         echo "✅ Code downloaded"
        //         sh """ls -al"""

        //         // script {
        //         //     env.FORCED_ACTION = 'playbook'  // Assign 'playbook' to a new environment variable
        //         //     echo "Forced ACTION to: ${env.FORCED_ACTION}"  // For debugging
        //         // }
        //     }
        // }
    
        // stage('Terraform Init') {
        //     steps {                
        //         dir('demo1_ss_infra/terraform/app_Infra') {
        //             sh """
        //                 echo "🔧 Initializing Terraform..."
        //                 terraform init
        //             """
        //         }
        //     }
        // }
        
        // stage('Terraform Plan') {
        //     when {
        //         anyOf {
        //             expression { params.ACTION == 'plan' }
        //             expression { params.ACTION == 'apply' }
        //             expression { env.IS_PR == 'true' }
        //         }
        //     }
        //     steps {
                
        //         dir('demo1_ss_infra/terraform/app_Infra') {
        //             sh """
        //                 echo "📋 Generating plan for ${params.ENVIRONMENT}..."
        //                 terraform plan -out=tfplan
        //                 terraform show -no-color tfplan > plan.txt
        //             """
                    
        //             archiveArtifacts artifacts: 'plan.txt'
        //         }
        //     }
        // }
        
        // stage('Terraform Apply') {
        //     when {
        //         expression { params.ACTION == 'apply' }
        //     }
        //     steps {
                
        //         dir('demo1_ss_infra/terraform/app_Infra') {
        //             sh '''
        //                 echo "🚀 Applying changes..."
        //                 terraform apply tfplan
        //             '''            
        //         }
        //     }
        // }
        
        // stage('Terraform Destroy') {
        //     when {
        //         expression { params.ACTION == 'destroy' }
        //     }
        //     steps {
        //         dir('demo1_ss_infra/terraform/app_Infra') {
        //             sh 'terraform destroy -auto-approve'
        //         }
        //     }
        // }
        
        stage('Run Ansible Playbook') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'playbook' }
                //expression { env.FORCED_ACTION == 'playbook' }
            }
            steps {
                // dir('demo1_ss_infra') {     
                    // script {
                    //     def appServerIp = readFile('/var/jenkins_home/app_server_ip.txt').trim()
                    //     env.APP_SERVER_IP = appServerIp
                    // }
                    // sh """
                    //     ansible-playbook \\
                    //         -i /var/jenkins_home/shared/hosts.ini \\
                    //         ansible/playbooks/infra_playbook.yml \\
                    //         --ssh-common-args='-o StrictHostKeyChecking=no'
                    // """
                // }
                sh 'echo "[ssh_connection]\nssh_args = -o ControlMaster=no" | tee /var/jenkins_home/workspace/test/ansible.cfg'
                sh 'echo $ANSIBLE_CONFIG'
                ansiblePlaybook credentialsId: 'ssh-key-appserver', disableHostKeyChecking: true, installation: 'Ansible', inventory: '/var/jenkins_home/shared/hosts.ini', playbook: '/var/jenkins_home/workspace/test/demo1_ss_infra/ansible/playbooks/infra_playbook.yml', vaultTmpPath: ''
            }
        }

        stage('Update infisical secrets') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    def db_host = readFile('/var/jenkins_home/shared/db_endpoint.txt').trim()
                    sh """
                        infisical secrets set DB_HOST="${db_host}" \
                        --env=prod \
                        --projectId=${INFISICAL_PROJECT_ID} \
                        --token=${INFISICAL_TOKEN}
                    """
                }
            }
        }
    }
    
    post {
        always {
            dir('demo1_ss_infra/terraform/app_Infra') {
                sh 'rm -f tfplan plan.txt || true'
            }
        }
        success {
            discordSend description: "Jenkins pipeline '${env.JOB_NAME}', action '${params.ACTION}', Build ${env.BUILD_DISPLAY_NAME} successful", 
                        footer: "", 
                        link: env.BUILD_URL, 
                        result: currentBuild.currentResult, 
                        title: "Infrastructure Pipeline", 
                        webhookURL: 'https://discord.com/api/webhooks/1383560954637189302/Ge7_KdL1a2YBpVfZ4v39mNnY0MTX05MwwxcIdd1mWIrAYJhvn3hqEfKy3nY5dct7Ggrb'
            echo '✅ Pipeline finished successfully'
        }
        failure {
            discordSend description: "Jenkins pipeline '${env.JOB_NAME}', action '${params.ACTION}', Build ${env.BUILD_DISPLAY_NAME} failed", 
                        footer: "", 
                        link: env.BUILD_URL, 
                        result: currentBuild.currentResult, 
                        title: "Infrastructure Pipeline", 
                        webhookURL: 'https://discord.com/api/webhooks/1383560954637189302/Ge7_KdL1a2YBpVfZ4v39mNnY0MTX05MwwxcIdd1mWIrAYJhvn3hqEfKy3nY5dct7Ggrb'
            echo '❌ Pipeline failed'
        }
    }
}