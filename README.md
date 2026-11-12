# Modular AWS Terraform Project

A beginner-friendly, production-style modular Terraform project targeting Amazon Web Services (AWS). It demonstrates how to decouple infrastructure into reusable child modules managed from a central root module.

---

## Architecture Overview

```
                      +-------------------+
                      |    AWS Provider   |
                      +---------+---------+
                                |
       +----------------+-------+--------+----------------+
       |                |                |                |
+------v------+  +------v------+  +------v------+  +------v------+
| modules/vpc |  | modules/s3  |  | modules/iam |  | modules/ecs |
+------+------+  +-------------+  +------+------+  +------+------+
       |                                 |                ^
       |   vpc_id, subnet_ids            |                |
       +---------------------------------+----------------+
                                         |
                       execution_role_arn|
                                         +----------------+
```

### Components Deployed
1. **Networking (`modules/vpc`)**:
   - 1 Amazon VPC.
   - 1 Internet Gateway (IGW) attached to the VPC.
   - 3 Public subnets distributed across 3 distinct Availability Zones.
   - 1 Public Route Table directing outbound traffic (`0.0.0.0/0`) to the IGW, associated with all 3 subnets.
2. **Storage (`modules/s3`)**:
   - 1 Amazon S3 bucket with a unique name generated using `bucket_prefix` and a random suffix.
   - Public access block enforcing complete privacy.
3. **Identity & Access Management (`modules/iam`)**:
   - 1 IAM role assumed by ECS tasks (`ecs-tasks.amazonaws.com`).
   - Attached AWS-managed policy `AmazonECSTaskExecutionRolePolicy`.
4. **Compute & Containers (`modules/ecs`)**:
   - 1 Amazon ECS Cluster.
   - 1 Amazon CloudWatch Log Group for container logs.
   - 1 Security Group allowing inbound HTTP traffic on port 80 and unrestricted egress.
   - 1 ECS Fargate Task Definition (256 CPU, 512 MB RAM, public Nginx image).
   - 1 ECS Fargate Service running `desired_count` instances with public IPs assigned.

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
    │   ├── main.tf            # VPC, Subnets, IGW, Route Table
    │   ├── variables.tf
    │   └── outputs.tf
    ├── s3/
    │   ├── main.tf            # S3 bucket and public access block
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/
    │   ├── main.tf            # ECS task execution IAM role & policy attachment
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecs/
        ├── main.tf            # Cluster, Log Group, SG, Task Definition, Service
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
Once applied, view outputs such as the VPC ID, subnet IDs, bucket name, cluster name, and service name:
```bash
terraform output
```

### 6. Clean Up
To destroy all created resources and avoid unexpected AWS charges:
```bash
terraform destroy
```

