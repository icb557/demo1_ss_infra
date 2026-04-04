# Infrastructure as Code Repository

This repository contains Infrastructure as Code (IaC) for provisioning and managing cloud infrastructure using Terraform and Ansible, with automated CI/CD pipelines through Jenkins.

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Usage Instructions](#usage-instructions)
- [Branching Strategy](#branching-strategy)
- [Versioning Approach](#versioning-approach)
- [How to Contribute](#how-to-contribute)
- [CI/CD Pipeline](#cicd-pipeline)
- [Requirements](#requirements)

## Overview

This repository manages infrastructure for:
- **Application Infrastructure**: VPC, EC2 instances, Auto Scaling Groups, Load Balancers, RDS databases, and security configurations
- **CI/CD Infrastructure**: Jenkins server, networking, and compute resources for automation
- **Configuration Management**: Ansible playbooks for server provisioning and application deployment

## Repository Structure

```
.
├── README.md                      # This file
├── Jenkinsfile                    # CI/CD pipeline definition
├── docker-compose.yml             # Local development environment
├── dockerfile                     # Jenkins agent Docker image
├── test-pipeline.groovy           # Pipeline testing utilities
├── .github/                       # GitHub workflows and configurations
├── ansible/                       # Configuration management
│   ├── inventories/               # Ansible inventory files
│   └── playbooks/                 # Ansible playbooks for provisioning
├── terraform/                     # Infrastructure as Code
│   ├── app_Infra/                 # Application infrastructure
│   │   ├── main.tf                # Main application infrastructure
│   │   ├── providers.tf           # Provider configurations
│   │   ├── variables.tf           # Input variables
│   │   ├── outputs.tf             # Output values
│   │   ├── datasources.tf         # Data sources
│   │   ├── locals.tf              # Local values
│   │   ├── terraform.tfvars       # Variable values
│   │   └── modules/               # Reusable Terraform modules
│   │       ├── compute/           # EC2, ASG, ELB modules
│   │       ├── database/          # RDS database modules
│   │       └── networking/        # VPC, Security Groups, NACLs
│   └── cicd_Infra/                # CI/CD infrastructure
│       ├── main.tf                # Jenkins and CI/CD resources
│       ├── providers.tf           # Provider configurations
│       ├── variables.tf           # Input variables
│       ├── outputs.tf             # Output values
│       ├── terraform.tfvars       # Variable values
│       └── modules/               # CI/CD specific modules
│           ├── compute/           # Jenkins server resources
│           └── networking/        # CI/CD networking
└── terragrunt/                    # Terragrunt configurations (optional)
```

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.9
- AWS CLI configured with appropriate credentials
- Jenkins server (for CI/CD automation)

### Initial Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/demo1_ss_infra.git
   cd demo1_ss_infra
   ```

2. Configure AWS credentials:
   ```bash
   aws configure
   ```

3. Review and update variable files:
   ```bash
   # For application infrastructure
   vim terraform/app_Infra/terraform.tfvars
   
   # For CI/CD infrastructure
   vim terraform/cicd_Infra/terraform.tfvars
   ```

## Usage Instructions

### Deploying Application Infrastructure

1. Navigate to the application infrastructure directory:
   ```bash
   cd terraform/app_Infra
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the execution plan:
   ```bash
   terraform plan
   ```

4. Apply the infrastructure changes:
   ```bash
   terraform apply
   ```

5. View outputs (e.g., instance IPs, load balancer DNS):
   ```bash
   terraform output
   ```

### Deploying CI/CD Infrastructure

1. Navigate to the CI/CD infrastructure directory:
   ```bash
   cd terraform/cicd_Infra
   ```

2. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Running Ansible Playbooks

1. Update inventory with target hosts:
   ```bash
   vim ansible/inventories/hosts.ini
   ```

2. Execute a playbook:
   ```bash
   ansible-playbook -i ansible/inventories/hosts.ini ansible/playbooks/your-playbook.yml
   ```

### Destroying Infrastructure

To tear down resources when no longer needed:

```bash
# Destroy application infrastructure
cd terraform/app_Infra
terraform destroy

# Destroy CI/CD infrastructure
cd terraform/cicd_Infra
terraform destroy
```

## Branching Strategy

This repository follows a **Feature Branch Workflow** with JIRA ticket integration:

### Branch Naming Convention

- **Main Branch**: `main` (protected)
- **Feature Branches**: `{JIRA-TICKET-ID}-{short-description}`
  - Example: `FAD-42-add-rds-module`

### Workflow

1. **Create a Feature Branch**:
   ```bash
   git checkout -b FAD-123-feature-description
   ```

2. **Make Changes**: Commit your infrastructure or configuration changes
   ```bash
   git add .
   git commit -m "FAD-123: Add RDS database module"
   ```

3. **Push to Remote**:
   ```bash
   git push origin FAD-123-feature-description
   ```

4. **Create a Pull Request (PR)**:
   - Open a PR from your feature branch to `main`
   - The CI/CD pipeline will automatically run `terraform plan`
   - Review the plan output in the PR comments

5. **Code Review & Approval**:
   - At least one reviewer must approve the PR
   - Address any feedback or requested changes

6. **Merge to Main**:
   - Once approved and all checks pass, merge the PR into `main`
   - The feature branch can be deleted after merge

### Branch Protection Rules

The `main` branch is protected with the following rules:
- Require pull request reviews before merging
- Require status checks to pass (CI/CD pipeline must succeed)
- No direct commits to `main` allowed

## Versioning Approach

This repository uses **Semantic Versioning** with Git tags for releases:

### Version Format

`vMAJOR.MINOR.PATCH` (e.g., `v1.0.0`, `v2.1.3`)

- **MAJOR**: Significant infrastructure changes or breaking changes
- **MINOR**: New features, modules, or non-breaking enhancements
- **PATCH**: Bug fixes, minor improvements, documentation updates

### Current Releases

- **v1.0.0**: Demo 1 Release (baseline infrastructure through June 6, 2025)
- **v2.0.0**: Demo 2 Release (enhanced infrastructure through June 20, 2025)

### Creating a Release

1. **Tag a Release**:
   ```bash
   git tag -a v1.0.0 <commit-hash> -m "Release v1.0.0: Description"
   ```

2. **Push Tags to Remote**:
   ```bash
   git push origin v1.0.0
   # Or push all tags
   git push origin --tags
   ```

3. **Create GitHub Release**:
   - Navigate to "Releases" in GitHub
   - Click "Create a new release"
   - Select the tag and add release notes

## How to Contribute

We welcome contributions! Follow these steps to contribute to this repository:

### 1. Find or Create a JIRA Ticket

Ensure there's a JIRA ticket for the work you're planning. This helps track changes and link them to requirements.

### 2. Fork and Clone (External Contributors)

For external contributors:
```bash
git clone https://github.com/your-username/demo1_ss_infra.git
cd demo1_ss_infra
git remote add upstream https://github.com/original-org/demo1_ss_infra.git
```

### 3. Create a Feature Branch

```bash
git checkout -b FAD-XXX-descriptive-name
```

### 4. Make Your Changes

- Follow existing code structure and naming conventions
- Update documentation if adding new features
- Test your changes locally before pushing

### 5. Commit Guidelines

Write clear, descriptive commit messages:
```bash
git commit -m "FAD-XXX: Brief description of change

Detailed explanation if needed:
- What changed
- Why it changed
- Any breaking changes or considerations"
```

### 6. Push and Create PR

```bash
git push origin FAD-XXX-descriptive-name
```

Then create a Pull Request on GitHub with:
- Clear title referencing the JIRA ticket
- Description of changes made
- Any testing performed
- Screenshots (if UI-related)

### 7. Code Review Process

- Address reviewer feedback promptly
- Keep discussions focused and professional
- Update your branch if conflicts arise with `main`

### 8. After Merge

Delete your feature branch:
```bash
git branch -d FAD-XXX-descriptive-name
git push origin --delete FAD-XXX-descriptive-name
```

## CI/CD Pipeline

### Features

- Automatic execution of `terraform plan` on each Pull Request
- Publication of the plan as a GitHub Gist in the PR
- Requires explicit approval in the PR before executing `terraform apply`
- Prevents merging of the PR until the plan is approved and applied
- Ansible playbook execution for configuration management

### Pipeline Stages

1. **Checkout**: Clone repository and checkout branch
2. **Terraform Init**: Initialize Terraform working directory
3. **Terraform Validate**: Validate Terraform configuration syntax
4. **Terraform Plan**: Generate and publish execution plan
5. **Approval Gate**: Wait for manual approval in PR
6. **Terraform Apply**: Apply approved infrastructure changes
7. **Ansible Provisioning**: Run configuration management playbooks
8. **Post-deployment**: Update PR status and notifications

### Manual Pipeline Execution

To run the pipeline manually in Jenkins:

1. Open the job in Jenkins
2. Click "Build with Parameters"
3. Select:
   - **ACTION**: `validate`, `plan`, or `apply`
   - **ENVIRONMENT**: `dev`, `staging`, or `prod`
4. Click "Build"

## Requirements

### Tools

- **Terraform** >= 1.0
- **Ansible** >= 2.9
- **AWS CLI** >= 2.0
- **Git** >= 2.20

### Jenkins Plugins

- AWS Credentials Plugin
- Pipeline Plugin
- GitHub Integration Plugin
- Credentials Plugin
- Docker Plugin (for containerized builds)

### Jenkins Credentials

Configure the following credentials in Jenkins:
- `aws-credentials`: AWS access key and secret for resource provisioning
- `github-token`: GitHub personal access token with repo and gist permissions

### AWS Permissions

The AWS IAM user/role must have permissions for:
- EC2 (instances, security groups, VPCs)
- RDS (database instances)
- ELB/ALB (load balancers)
- Auto Scaling Groups
- IAM (for role creation)

## Troubleshooting

### Common Issues

**Terraform State Lock**:
```bash
# If state is locked, force unlock (use with caution)
terraform force-unlock <lock-id>
```

**AWS Credential Errors**:
```bash
# Verify credentials
aws sts get-caller-identity
```

**Ansible Connection Issues**:
```bash
# Test connectivity to hosts
ansible all -i inventories/hosts.ini -m ping
```

