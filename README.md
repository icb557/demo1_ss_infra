# Terraform Pipeline with PR Approval

This repository implements a CI/CD pipeline for Terraform that requires plan approval before applying changes, following Infrastructure as Code (IaC) best practices.

## Features

- Automatic execution of `terraform plan` on each Pull Request
- Publication of the plan as a GitHub Gist in the PR
- Requires explicit approval in the PR before executing `terraform apply`
- Prevents merging of the PR until the plan is approved and applied
- Support for multiple environments (dev, staging, prod)

## Requirements

- Jenkins with support for multibranch pipelines
- Jenkins plugins:
  - AWS Credentials Plugin
  - Pipeline
  - GitHub Integration
  - Credentials Plugin
- Credentials configured in Jenkins:
  - `aws-credentials`: AWS credentials to access resources
  - `github-token`: GitHub token with permissions to create Gists and comment on PRs

## Configuration

### 1. Configure credentials in Jenkins

1. In the Jenkins dashboard, navigate to "Manage Jenkins" > "Manage Credentials"
2. Add the following credentials:
   - **AWS Credentials**: Type "AWS Credentials", ID: "aws-credentials"
   - **GitHub Token**: Type "Secret text", ID: "github-token"

### 2. Configure the Jenkins pipeline

1. Create a new job of type "Multibranch Pipeline"
2. Configure the repository source (GitHub)
3. In "Branch Sources", enable "Discover pull requests from origin"
4. Save the configuration

### 3. Modify the Jenkinsfile

Update the following variables in the Jenkinsfile:

```groovy
environment {
    // ...
    REPO_OWNER = 'your-user-or-organization'
    REPO_NAME = 'repository-name'
    // ...
}
```

### 4. Configure branch protection in GitHub

To ensure the pipeline runs before allowing the merge:

1. In GitHub, go to "Settings" > "Branches" > "Branch protection rules"
2. Create a rule for the main branch (main/master)
3. Enable "Require status checks to pass before merging"
4. Search and select the "terraform-apply" check from Jenkins
5. Save the configuration

## Pipeline Usage

### Normal flow with Pull Requests

1. Create a new branch for your changes
2. Make changes to the Terraform configuration
3. Create a Pull Request
4. The pipeline will run automatically and:
   - Initialize Terraform
   - Validate the configuration
   - Execute `terraform plan`
   - Create a Gist with the full plan
   - Post a comment in the PR with a summary and the link to the Gist

5. To approve the plan, a reviewer must comment in the PR with:
   ```
   ✅ Approve plan
   ```

6. After approval, to apply the changes:
   - Manually select the parameter "ACTION" as "apply" in Jenkins
   - The pipeline will execute `terraform apply`
   - Post a comment indicating that the changes were applied
   - Update the PR status to allow merging

7. Once applied, the PR can be merged

### Manual execution

To run the pipeline manually:

1. Open the job in Jenkins
2. Click on "Build with Parameters"
3. Select:
   - **ACTION**: validate, plan, or apply
   - **ENVIRONMENT**: dev, staging, or prod
4. Click on "Build"

## Terraform Structure

The pipeline assumes the following directory structure:

```
/
├── Jenkinsfile
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── environments/
        ├── dev.tfvars
        ├── staging.tfvars
        └── prod.tfvars
```

## Troubleshooting

- **Error in Gist creation**: Verify that the GitHub token has permissions to create Gists
- **Error in PR comments**: Ensure that the token has permissions to comment on issues/PRs
- **The pipeline does not run on PRs**: Verify the Multibranch Pipeline configuration 