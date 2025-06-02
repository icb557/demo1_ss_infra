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
            choices: ['validate', 'plan', 'apply'],
            description: 'Terraform action'
        )
        choice(
            name: 'ENVIRONMENT', 
            choices: ['dev', 'staging', 'prod'],
            description: 'Environment'
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
                sh """git clone -b FAD-15-task https://github.com/${REPO_OWNER}/${REPO_NAME}"""
                echo "✅ Code downloaded"
                sh """ls -al"""
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
                    sh """
                        echo "🔧 Initializing Terraform..."
                        terraform init -backend-config="key=terraform.tfstate"
                    """
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                dir('demo1_ss_infra/terraform') {
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
                
                dir('demo1_ss_infra/terraform') {
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
                            withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                                def gistResponse = sh(
                                    script: """
                                        curl -X POST \
                                        -H "Authorization: token ${TOKEN}" \
                                        -H "Accept: application/vnd.github.v3+json" \
                                        -d '${gistContent}' \
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

                            withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                                sh """
                                    curl -X POST \
                                    -H "Authorization: token ${TOKEN}" \
                                    -H "Accept: application/vnd.github.v3+json" \
                                    -d '{"body": "${prComment.replaceAll("'", "\\'")}"}' \
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
                    def maxRetries = 10
                    def retryCount = 0
                    def sleepDuration = 60  // 1 minute
                    
                    echo "Waiting for plan approval in the PR..."
                    
                    while (!approved && retryCount < maxRetries) {
                        // Get PR comments to check for approval
                        withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                            def commentsResponse = sh(
                                script: """
                                    curl -s -H "Authorization: token ${TOKEN}" \
                                -H "Accept: application/vnd.github.v3+json" \
                                https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${env.PR_NUMBER}/comments
                                """,
                                returnStdout: true
                            ).trim()
                        }
                        def comments = readJSON text: commentsResponse
                        
                        // Check if any comment contains the approval message
                        approved = comments.any { comment -> 
                            comment.body.contains('✅ Approve plan')
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
                
                dir('demo1_ss_infra/terraform') {
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
                            
                            withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                                sh """
                                    curl -X POST \
                                    -H "Authorization: token ${TOKEN}" \
                                    -H "Accept: application/vnd.github.v3+json" \
                                    -d '{"body": "${applyComment.replaceAll("'", "\\'")}"}' \
                                    https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${env.PR_NUMBER}/comments
                                """
                            }
                            // Set PR status to success
                            withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                                sh """
                                    curl -X POST \
                                    -H "Authorization: token ${TOKEN}" \
                                    -H "Accept: application/vnd.github.v3+json" \
                                    -d '{"state": "success", "context": "terraform-apply", "description": "Terraform changes applied successfully", "target_url": "${env.BUILD_URL}"}' \
                                    https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/statuses/${env.GIT_COMMIT}
                                """
                            }
                        }
                    }
                }   
            }
        }
    }
    
    post {
        always {
            dir('demo1_ss_infra/terraform') {
                sh 'rm -f tfplan plan.txt || true'
            }
        }
        success {
            echo "✅ Pipeline completed successfully"
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

                    withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                        sh """
                            curl -X POST \
                            -H "Authorization: token ${TOKEN}" \
                            -H "Accept: application/vnd.github.v3+json" \
                            -d '{"body": "${failureComment.replaceAll("'", "\\'")}"}' \
                            https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${env.PR_NUMBER}/comments
                        """
                        
                        echo "Debug: Attempting to fetch PR head commit SHA..."
                        def prHeadSha = sh(script: 'git rev-parse refs/pull/${env.CHANGE_ID}/head', returnStdout: true).trim()
                        echo "Debug: Using PR head SHA: ${prHeadSha}"
                        try {
                            withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]) {
                                sh '''
                                    curl -X POST \
                                    -H "Authorization: token $TOKEN" \
                                    -H "Accept: application/vnd.github.v3+json" \
                                    -d '{"state": "failure", "context": "terraform-pipeline", "description": "Terraform pipeline failed", "target_url": "' + "${env.BUILD_URL}" + '"}' \
                                    https://api.github.com/repos/' + "${REPO_OWNER}/${REPO_NAME}/statuses/" + "${prHeadSha}"
                                '''
                            }
                        } catch (error) {
                            echo "Error setting commit status: " + error.getMessage()
                        }
                    }
                }
            }
        }
    }
} 