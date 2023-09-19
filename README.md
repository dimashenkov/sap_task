# Terraform AWS Microblog Deployment

This project deploys a Microblog application on AWS using ECS with Fargate and Aurora RDS.

## Overview

1. **Docker Hub:** Microblog application image is hosted on Docker Hub.
2. **ALB:** Application Load Balancer handling incoming traffic.
3. **ECS with Fargate:** Scalable, serverless containerized deployment.
4. **Aurora RDS:** Managed relational database service for the application.

## Key Resources

- **Security Groups:** Define traffic rules for ALB and Microblog containers.
- **IAM Roles:** Task execution and task roles for permissions.
- **SecretsManager:** Manages sensitive data like database passwords and registry tokens.
- **CloudWatch Log Groups:** For logging ECS task executions.

## Quickstart

1. **Setup Terraform**: Install Terraform and initialize the project.
2. **Configure Secrets**: Ensure all secrets in AWS SecretsManager are correctly set up.
3. **Verify Docker Hub Image**: Ensure the Microblog application image is available on Docker Hub.
4. **Deploy**: Run `terraform apply` to deploy resources on AWS.

Remember to keep your secrets and sensitive data out of version control. Always use AWS SecretsManager or a similar service to manage them.

## Service Fail-Over

### Auto-recovery for ECS with Fargate
If a task in ECS fails, the service scheduler launches another instance of the task in the ECS cluster to replace it. This offers inherent fail-over capability.

### Auto-recovery for RDS
RDS Multi-AZ deployments provide high availability and failover support for DB instances.
