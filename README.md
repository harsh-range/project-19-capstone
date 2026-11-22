# Project 19: Scheduled S3 Backup

## Objective
Automate log backups to Amazon S3 using Terraform and a cron job.

## Components
- Amazon S3 Bucket
- EC2 Instance
- Backup Script
- Cron Job

## Deployment
```bash
terraform init
terraform apply -auto-approve
```

## Verification
```bash
aws s3 ls s3://harsh-project19-backup-0e74a83a
```

