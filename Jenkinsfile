pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_CLI_ARGS = '-no-color'
        GITHUB_TOKEN = credentials('github-token')
        REPO_OWNER = 'icb557'
        REPO_NAME = 'demo1_ss_infra'
        PR_NUMBER = "${env.CHANGE_ID}"
        IS_PR = "${env.CHANGE_ID ? true : false}"
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
                sh """git clone -b FAD-44-task https://github.com/${REPO_OWNER}/${REPO_NAME}"""
                echo "✅ Code downloaded"
                sh """ls -al"""

                // script {
                //     env.FORCED_ACTION = 'playbook'  // Assign 'playbook' to a new environment variable
                //     echo "Forced ACTION to: ${env.FORCED_ACTION}"  // For debugging
                // }
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
                dir('demo1_ss_infra/terraform/app_Infra') {
                    sh """
                        echo "🔧 Initializing Terraform..."
                        terraform init -backend-config="key=terraform.tfstate"
                    """
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                dir('demo1_ss_infra/terraform/app_Infra') {
                    sh '''
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
                    sh """
                        echo "📋 Generating plan for ${params.ENVIRONMENT}..."
                        terraform plan -out=tfplan
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
                                    script: """
                                        curl -X POST \\
                                        -H "Authorization: token $TOKEN" \\
                                        -H "Accept: application/vnd.github.v3+json" \\
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
                                sh """
                                    curl -X POST \\
                                    -H "Authorization: token $TOKEN" \\
                                    -H "Accept: application/vnd.github.v3+json" \\
                                    -H "Content-Type: application/json" \\
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
                    sh '''
                        echo "🚀 Applying changes..."
                        terraform apply tfplan
                    '''
                    
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
                                sh """
                                    curl -X POST \\
                                    -H "Authorization: token $TOKEN" \\
                                    -H "Accept: application/vnd.github.v3+json" \\
                                    -H "Content-Type: application/json" \\
                                    -d '${jsonPayload}' \\
                                    https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${env.PR_NUMBER}/comments
                                """
                            }
                        }
                    }
                }   
            }
        }
        
        stage('Set Environment Variables') {
            steps {
                dir('demo1_ss_infra/terraform/app_Infra') {
                    script {
                        def appServerIp = sh(script: 'terraform output -raw app_server_public_ip', returnStdout: true).trim()
                        env.APP_SERVER_IP = appServerIp
                        echo "Set APP_SERVER_IP to ${env.APP_SERVER_IP}"
                        sh 'echo $APP_SERVER_IP > /var/jenkins_home/app_server_ip.txt'
                    }
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' && env.IS_PR != 'true' }
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
                // script {
                //     def appServerIp = readFile('/var/jenkins_home/app_server_ip.txt').trim()
                //     env.APP_SERVER_IP = appServerIp
                // }
                sh 'echo $APP_SERVER_IP'
                ansiblePlaybook(
                    playbook: 'ansible/playbooks/infra_playbook.yml',
                    inventory: 'ansible/inventories/hosts.ini',
                    credentialsId: 'ssh-key-appserver'
                )
            }
        }

        stage('Copy hosts file to shared path'){
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'playbook' }
                //expression { env.FORCED_ACTION == 'playbook' }
            }
            steps {
                sh 'cp ansible/inventories/hosts.ini /var/jenkins_home/hosts.ini'
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
            echo "✅ Pipeline completed successfully"
            script {
                if (env.IS_PR == 'true') {
                    withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                        sh '''
                            curl -L \\
                            -X PUT \\
                            -H "Accept: application/vnd.github+json" \\ 
                            -H "Authorization: Bearer $TOKEN" \\
                            -H "X-GitHub-Api-Version: 2022-11-28" \\
                            https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/pulls/${env.PR_NUMBER}/merge \\ 
                            -d '{"commit_title":"merge PR: ${env.PR_NUMBER}"}'
                        '''
                    }
                }
            }
        }
        failure {
            echo "❌ Pipeline failed"
            
            script {
                if (env.IS_PR == 'true') {
                    // Comment on PR about failure
                    def failureComment = """
                    ### ❌ Pipeline failed
                    
                    The Terraform pipeline has failed. Please check the [Jenkins logs](${env.BUILD_URL}) for more details.
                    """
                    
                    def jsonPayload = groovy.json.JsonOutput.toJson([body: failureComment])

                    withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                        sh """
                            curl -X POST \\
                            -H "Authorization: token $TOKEN" \\
                            -H "Accept: application/vnd.github.v3+json" \\
                            -H "Content-Type: application/json" \\
                            -d '${jsonPayload}' \\
                            https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${env.PR_NUMBER}/comments
                        """
                        
                        // echo "Debug: Attempting to fetch PR head commit SHA..."
                        // def prHeadSha = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                        // echo "Debug: Using commit SHA: ${prHeadSha}"
                        // try {
                        //     def statusPayload = groovy.json.JsonOutput.toJson([
                        //         state: "failure",
                        //         context: "terraform-pipeline",
                        //         description: "Terraform pipeline failed",
                        //         target_url: "${env.BUILD_URL}"
                        //     ])
                            
                        //     withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                        //         sh """
                        //             curl -X POST \\
                        //             -H "Authorization: token $TOKEN" \\
                        //             -H "Accept: application/vnd.github.v3+json" \\
                        //             -H "Content-Type: application/json" \\
                        //             -d '${statusPayload}' \\
                        //             https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/statuses/${prHeadSha}
                        //         """
                        //     }
                        // } catch (error) {
                        //     echo "Error setting commit status: " + error.getMessage()
                        // }
                    }
                }
            }
        }
    }
} 