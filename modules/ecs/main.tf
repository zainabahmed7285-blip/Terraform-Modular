# ==============================================================================
# ECS MODULE - MAIN CONFIGURATION
# ==============================================================================
# This module creates:
# 1. An Amazon ECS cluster
# 2. An Amazon CloudWatch log group for container stdout/stderr logs
# 3. An ECS Fargate Task Definition configured with container image, port,
#    database environment variables (DB_HOST, DB_PORT, DB_NAME), and database
#    secrets (DB_USER, DB_PASSWORD) retrieved from AWS Secrets Manager
# 4. An ECS Fargate Service running in public subnets with app_sg_id security group
# ==============================================================================

# Fetch current AWS region dynamically for CloudWatch log configuration
data "aws_region" "current" {}

# 1. ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 2. CloudWatch Log Group for ECS task logs
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Name        = "/ecs/${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 3. Fargate Task Definition (256 CPU, 512 MB Memory)
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DB_HOST"
          value = var.db_host
        },
        {
          name  = "DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        }
      ]
      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-${var.environment}-task-def"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 4. ECS Fargate Service
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.app_sg_id]
    assign_public_ip = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-service"
    Environment = var.environment
    Project     = var.project_name
  }
}
