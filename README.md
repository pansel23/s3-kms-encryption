
# S3 Bucket Encryption with AWS KMS Using Terraform

## Description
This project provisions an AWS S3 bucket encrypted with a customer-managed AWS KMS key using Terraform. It also sets up necessary IAM policies and integrates GitHub Actions for CI/CD.

## Features
- AWS S3 Bucket with KMS encryption
- AWS KMS Key with alias and policy
- IAM Policy and User for access control
- GitHub Actions CI/CD for Terraform workflows

## Prerequisites
- Terraform >= 1.6.6
- AWS CLI configured locally
- AWS account and IAM credentials with appropriate permissions

## How to Use

1. Clone the repository:
```bash
git clone https://github.com/<your-username>/s3-kms-terraform.git
cd s3-kms-terraform
```

2. Initialize Terraform:
```bash
terraform init
```

3. Format and Validate:
```bash
terraform fmt
terraform validate
```

4. Plan and Apply:
```bash
terraform plan
terraform apply
```

## CI/CD Setup
- Configure AWS credentials as GitHub Secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- Push changes to `main` branch to trigger the workflow.

## Notes
- Adjust IAM usernames and resource names as per your environment.
- Use a remote backend for production environments.
