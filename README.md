# Modular AWS Terraform Project

A beginner-friendly, production-style modular Terraform project targeting Amazon Web Services (AWS). It demonstrates how to decouple infrastructure into reusable child modules managed from a central root module.

---

## Architecture Overview

```
                                  +-------------------+
                                  |    AWS Provider   |
                                  +---------+---------+
                                            |
         +----------------+-----------------+-----------------+-----------------+
         |                |                 |                 |                 |
  +------v------+  +------v------+   +------v------+   +------v------+   +------v------+
  | modules/vpc |  | modules/s3  |   | modules/rds |   | modules/iam |   | modules/ecs |
  +------+------+  +-------------+   +------+------+   +------+------+   +------+------+
         |                                  |                 ^                 ^
         |   app_sg_id, subnet_ids          |                 |                 |
         +----------------------------------+-----------------+-----------------+
         |                                  |                 |                 |
         |                                  | secret_arn      |                 |
         |                                  +-----------------+                 |
         |                                  |                                   |
         |                                  | db_address, db_port, db_name,     |
         |                                  | secret_arn                        |
         |                                  +-----------------------------------+
         |                                                    |
         |                                  execution_role_arn|
         +----------------------------------------------------+
```

### Components Deployed
1. **Networking (`modules/vpc`)**:
   - 1 Amazon VPC.
   - 1 Internet Gateway (IGW) attached to the VPC.
   - 3 Public subnets distributed across 3 distinct Availability Zones.
   - 1 Public Route Table directing outbound traffic (`0.0.0.0/0`) to the IGW, associated with all 3 subnets.
   - 1 Application Security Group (`app_sg_id`) allowing inbound traffic on `container_port` from anywhere and unrestricted egress.
2. **Storage (`modules/s3`)**:
   - 1 Amazon S3 bucket with a unique name generated using `bucket_prefix` and a random suffix.
   - Public access block enforcing complete privacy.
3. **Database (`modules/rds`)**:
   - 1 RDS DB Subnet Group across the provided subnets.
   - 1 RDS Security Group allowing inbound PostgreSQL (TCP 5432) ONLY from `app_sg_id`.
   - 1 Amazon RDS PostgreSQL DB instance (`db.t3.micro`, 20 GB storage, `manage_master_user_password = true` with AWS Secrets Manager).
4. **Identity & Access Management (`modules/iam`)**:
   - 1 IAM role assumed by ECS tasks (`ecs-tasks.amazonaws.com`).
   - Attached AWS-managed policy `AmazonECSTaskExecutionRolePolicy`.
   - IAM role inline policy granting `secretsmanager:GetSecretValue` on `module.rds.secret_arn`.
5. **Compute & Containers (`modules/ecs`)**:
   - 1 Amazon ECS Cluster.
   - 1 Amazon CloudWatch Log Group for container logs.
   - 1 ECS Fargate Task Definition with environment variables (`DB_HOST`, `DB_PORT`, `DB_NAME`) and secrets (`DB_USER`, `DB_PASSWORD`) pulled from AWS Secrets Manager.
   - 1 ECS Fargate Service using `app_sg_id` in public subnets with `assign_public_ip = true`.

---

## Directory Structure

```
Terraform Modular/
├── .gitignore
├── README.md
├── main.tf                    # Root module: provider & module calls
├── variables.tf               # Root input variables
├── outputs.tf                 # Root output values
├── terraform.tfvars.example   # Example variable values
└── modules/
    ├── vpc/
    │   ├── main.tf            # VPC, Subnets, IGW, Route Table, App Security Group
    │   ├── variables.tf
    │   └── outputs.tf
    ├── s3/
    │   ├── main.tf            # S3 bucket and public access block
    │   ├── variables.tf
    │   └── outputs.tf
    ├── rds/
    │   ├── main.tf            # DB Subnet Group, DB SG, PostgreSQL DB Instance
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/
    │   ├── main.tf            # ECS task execution role & Secrets Manager access policy
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecs/
        ├── main.tf            # Cluster, Log Group, Task Definition (DB env/secrets), Service
        ├── variables.tf
        └── outputs.tf
```

---

## Getting Started

### 1. Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.0.0) installed.
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid AWS credentials (`aws configure`).

### 2. Configure Variables
Copy the example variables file and adjust as needed:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region        = "eu-north-1"
environment       = "dev"
project_name      = "demo-project"
vpc_cidr          = "10.0.0.0/16"
bucket_prefix     = "demo-storage"
ecs_desired_count = 2
container_image   = "<account-id>.dkr.ecr.eu-north-1.amazonaws.com/study-planner:latest"
container_port    = 5000
```

### 3. Initialize & Validate
Initialize providers and child modules:
```bash
terraform init
```

Format and validate the configuration:
```bash
terraform fmt -recursive
terraform validate
```

### 4. Deploy Infrastructure
Review the execution plan:
```bash
terraform plan
```

Apply the changes to your AWS account:
```bash
terraform apply
```

### 5. Inspect Outputs
Once applied, view outputs such as the VPC ID, subnet IDs, bucket name, cluster name, service name, database endpoint, and database name:
```bash
terraform output
```

### 6. Clean Up
To destroy all created resources and avoid unexpected AWS charges:
```bash
terraform destroy
```
