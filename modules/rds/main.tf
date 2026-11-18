# ==============================================================================
# RDS MODULE - MAIN CONFIGURATION
# ==============================================================================
# This module creates:
# 1. A DB subnet group across the provided subnets
# 2. A database security group allowing inbound PostgreSQL (port 5432) ONLY from app_sg_id
# 3. An Amazon RDS PostgreSQL instance with master password managed by AWS Secrets Manager
# ==============================================================================

# 1. DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for ${var.project_name} ${var.environment} RDS instance"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 2. RDS Security Group (allows TCP 5432 ONLY from the app security group)
resource "aws_security_group" "db" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for RDS PostgreSQL database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow inbound PostgreSQL from app security group only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 3. RDS PostgreSQL DB Instance
resource "aws_db_instance" "main" {
  identifier                  = "${var.project_name}-${var.environment}-db"
  engine                      = "postgres"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  db_name                     = "studyplanner"
  username                    = "dbadmin"
  manage_master_user_password = true
  publicly_accessible         = false
  multi_az                    = false
  skip_final_snapshot         = true
  deletion_protection         = false
  db_subnet_group_name        = aws_db_subnet_group.main.name
  vpc_security_group_ids      = [aws_security_group.db.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
    Project     = var.project_name
  }
}
