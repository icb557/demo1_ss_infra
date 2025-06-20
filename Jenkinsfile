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
        PR_NUMBER = "${env.CHANGE_ID}"
        IS_PR = "${env.CHANGE_ID ? true : false}"
        INFISICAL_TOKEN = credentials('infisical-token-id')
        INFISICAL_PROJECT_ID = credentials('infisical-project-id')
        // ANSIBLE_CONFIG = "${WORKSPACE}/ansible.cfg"
        DISCORD_WEBHOOK= credentials('discord-webhook')
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'validate', 'plan', 'destroy', 'playbook'],
            description: 'Terraform action',
        )
        choice(
            name: 'ENVIRONMENT', 
            choices: ['dev', 'staging', 'prod'],
            description: 'Environment',
        )
        booleanParam(
            name: 'SKIP_APPROVAL',
            defaultValue: false,
            description: 'Skip manual approval for the apply stage'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh """#!/bin/bash
git clone -b FAD-42-task https://github.com/${REPO_OWNER}/${REPO_NAME}
echo "✅ Code downloaded"
ls -al
"""

                // script {
                //     env.FORCED_ACTION = 'playbook'  // Assign 'playbook' to a new environment variable
                //     echo "Forced ACTION to: ${env.FORCED_ACTION}"  // For debugging
                // }
            }
        }
        
        stage('Terraform Version') {
            steps {
                sh """#!/bin/bash
terraform --version
aws --version
"""
            }
        }
        
        stage('Terraform Init') {
            steps {                
                dir('demo1_ss_infra/terraform/app_Infra') {
                    sh """#!/bin/bash
echo "🔧 Initializing Terraform..."
terraform init
"""
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                dir('demo1_ss_infra/terraform/app_Infra') {
                    sh '''#!/bin/bash
echo "✅ Validating configuration..."
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
                    expression { env.IS_PR == 'true' }
                }
            }
            steps {
                
                dir('demo1_ss_infra/terraform/app_Infra') {
                    sh """#!/bin/bash
echo "📋 Generating plan for ${params.ENVIRONMENT}..."
terraform plan -var 'infisical_project_id=${env.INFISICAL_PROJECT_ID}' -var 'infisical_token=${env.INFISICAL_TOKEN}' -out=tfplan
terraform show -no-color tfplan > plan.txt
"""
                    
                    archiveArtifacts artifacts: 'plan.txt'
                    
                    script {
                        if (env.IS_PR == 'true') {
                            // Create GitHub Gist with the plan
                            def planContent = readFile('plan.txt')
                            def gistDescription = "Terraform Plan for PR #${env.PR_NUMBER} - ${env.JOB_NAME} #${env.BUILD_NUMBER}"
                            def gistFileName = "terraform-plan-pr-${env.PR_NUMBER}.txt"
                            
                            // Create Gist using GitHub API
                            def gistContent = """
                            {
                                "description": "${gistDescription}",
                                "public": false,
                                "files": {
                                "${gistFileName}": {
                                    "content": ${groovy.json.JsonOutput.toJson(planContent)}
                                }
                                }
                            }
                            """
                            def gistResponse = ""
                            withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                                gistResponse = sh(
                                    script: """#!/bin/bash
curl -X POST \\
-H \"Authorization: token $TOKEN\" \\
-H \"Accept: application/vnd.github.v3+json\" \\
-d '${gistContent}' \\
https://api.github.com/gists
""",
                                    returnStdout: true
                                ).trim()
                            }
                            def gistData = readJSON text: gistResponse
                            def gistUrl = gistData.html_url
                            
                            // Comment on PR with Gist link
                            def prComment = """
                            ### Terraform Plan 📋
                            
                            A Terraform plan has been generated for this PR.
                            [View the full plan here](${gistUrl})
                            
                            **Plan summary:**
                            ```
                            ${planContent.split('\n').findAll { it.contains('Plan:') || it.contains('No changes') }.join('\n')}
                            ```
                            
                            To approve this plan and allow its application, a reviewer must comment with: 
                            ✅ **Approve plan**
                            """
                            
                            def jsonPayload = groovy.json.JsonOutput.toJson([body: prComment])

                            withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                                sh """#!/bin/bash
curl -X POST \\
-H \"Authorization: token $TOKEN\" \\
-H \"Accept: application/vnd.github.v3+json\" \\
-H \"Content-Type: application/json\" \\
-d '${jsonPayload}' \\
https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${env.PR_NUMBER}/comments
"""
                            }
                            // Store Gist URL as environment variable for later stages
                            env.PLAN_GIST_URL = gistUrl
                        }
                    }
                }
            }
        }
        
        stage('Check PR Approval') {
            when {
                expression { env.IS_PR == 'true' && params.ACTION == 'apply' }
            }
            steps {
                script {
                    def approved = false
                    def maxRetries = 5
                    def retryCount = 0
                    def sleepDuration = 60  // 1 minute
                    
                    echo "Waiting for plan approval in the PR..."
                    
                    while (!approved && retryCount < maxRetries) {
                        // Get PR comments to check for approval
                        withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                            def commentsResponse = sh(
                                script: """
                                    curl -s -H "Authorization: token $TOKEN" \\
                                    -H "Accept: application/vnd.github.v3+json" \\
                                    https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${env.PR_NUMBER}/comments
                                """,
                                returnStdout: true
                            ).trim()
                            
                            // Process the comments inside the withCredentials block to keep variable in scope
                            def comments = readJSON text: commentsResponse

                            echo "Comments: ${comments}"

                            // Check if any comment contains the approval message
                            approved = comments.any { comment -> 
                                comment.body.contains('✅ Approve plan')
                            }
                        }
                        
                        if (approved) {
                            echo "✅ Plan approved in the PR. Proceeding with the application."
                            break
                        } else {
                            retryCount++
                            if (retryCount < maxRetries) {
                                echo "Waiting for approval... Attempt ${retryCount}/${maxRetries}"
                                sleep sleepDuration
                            } else {
                                error "⛔ Timeout reached. No approval received for the Terraform plan."
                            }
                        }
                    }
                }
            }
        }
        
        stage('Manual Approval') {
            when {
                expression { params.ACTION == 'apply' && env.IS_PR != 'true' }
            }
            steps {
                script {
                    if (!params.SKIP_APPROVAL) {
                        def planOutput = readFile('terraform/plan.txt')
                        def planSummary = planOutput.split('\n').findAll { it.contains('Plan:') || it.contains('No changes') }.join('\n')
                        input message: "¿Apply changes?\n\n${planSummary}", ok: 'Apply!'
                    } else {
                        echo 'Skipping manual approval as per parameter.'
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                
                dir('demo1_ss_infra/terraform/app_Infra') {
                    sh """#!/bin/bash
echo "🚀 Applying changes..."
terraform apply \
  -var 'infisical_project_id=${env.INFISICAL_PROJECT_ID}' \
  -var 'infisical_token=${env.INFISICAL_TOKEN}' \
  tfplan
"""
                    
                    script {
                        if (env.IS_PR == 'true') {
                            // Comment on PR that plan was applied
                            def applyComment = """
                            ### Terraform Apply completed ✅
                            
                            The Terraform plan has been applied successfully.
                            The PR can be merged now.
                            
                            [Original plan](${env.PLAN_GIST_URL})
                            """
                            
                            def jsonPayload = groovy.json.JsonOutput.toJson([body: applyComment])
                            
                            withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                                sh """#!/bin/bash
curl -X POST \\
-H \"Authorization: token $TOKEN\" \\
-H \"Accept: application/vnd.github.v3+json\" \\
-H \"Content-Type: application/json\" \\
-d '${jsonPayload}' \\
https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${env.PR_NUMBER}/comments
"""
                            }
                        }
                    }
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
        
        // stage('Run Ansible Playbook') {
        //     when {
        //         expression { params.ACTION == 'apply' || params.ACTION == 'playbook' }
        //     }
        //     steps {
        //         dir('demo1_ss_infra') {    
        //             sh 'echo "[ssh_connection]\nssh_args = -o ControlMaster=no" | tee ansible.cfg'
        //             sh 'echo $ANSIBLE_CONFIG'
        //             ansiblePlaybook credentialsId: 'ssh-key-appserver', disableHostKeyChecking: true, installation: 'Ansible', inventory: '/var/jenkins_home/shared/hosts.ini', playbook: 'ansible/playbooks/infra_playbook.yml', vaultTmpPath: ''
        //         }
        //     }
        // }

        stage('Update infisical secrets') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    def db_host = readFile('/var/lib/jenkins/agents/local-agent/shared/db_endpoint.txt').trim()
                    sh """#!/bin/bash
infisical secrets set DB_HOST=\"${db_host}\" \
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
                        webhookURL: env.DISCORD_WEBHOOK
            script {
                if (env.IS_PR == 'true') {
                    withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                        sh '''#!/bin/bash
curl -L \
-X PUT \
-H "Accept: application/vnd.github+json" \
-H "Authorization: Bearer $TOKEN" \
-H "X-GitHub-Api-Version: 2022-11-28" \
https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/pulls/${env.PR_NUMBER}/merge \
-d '{"commit_title":"merge PR: ${env.PR_NUMBER}"}'
'''
                    }
                }
            }
            echo "✅ Pipeline completed successfully"
        }
        failure {
            discordSend description: "Jenkins pipeline '${env.JOB_NAME}', action '${params.ACTION}', Build ${env.BUILD_DISPLAY_NAME} failed", 
                        footer: "", 
                        link: env.BUILD_URL, 
                        result: currentBuild.currentResult, 
                        title: "Infrastructure Pipeline", 
                        webhookURL: env.DISCORD_WEBHOOK
            script {
                if (env.IS_PR == 'true') {
                    // Comment on PR about failure
                    def failureComment = """
                    ### ❌ Pipeline failed
                    
                    The Terraform pipeline has failed. Please check the [Jenkins logs](${env.BUILD_URL}) for more details.
                    """
                    
                    def jsonPayload = groovy.json.JsonOutput.toJson([body: failureComment])

                    withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                        sh """#!/bin/bash
curl -X POST \\
-H \"Authorization: token $TOKEN\" \\
-H \"Accept: application/vnd.github.v3+json\" \\
-H \"Content-Type: application/json\" \\
-d '${jsonPayload}' \\
https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${env.PR_NUMBER}/comments
"""
                    }
                }
            }
            echo "❌ Pipeline failed"
        }
    }
} 
