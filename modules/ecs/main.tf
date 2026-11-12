# ==============================================================================
# ECS MODULE - MAIN CONFIGURATION
# ==============================================================================
# This module creates:
# 1. An Amazon ECS cluster
# 2. An Amazon CloudWatch log group for container stdout/stderr logs
# 3. A Security Group allowing inbound HTTP traffic on port 80 and all outbound
# 4. An ECS Fargate Task Definition (256 CPU, 512 RAM, public nginx image, port 80)
# 5. An ECS Fargate Service configured with assign_public_ip in the public subnets
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

# 3. Security Group for the ECS service
resource "aws_security_group" "ecs_service" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for ECS tasks allowing inbound HTTP port 80"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP requests on port 80 from the internet
  ingress {
    description = "Allow inbound HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic so containers can pull images and send logs
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 4. Fargate Task Definition (256 CPU, 512 MB Memory, Nginx container on port 80)
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-${var.environment}-nginx"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "public.ecr.aws/nginx/nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
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

# 5. ECS Fargate Service
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-service"
    Environment = var.environment
    Project     = var.project_name
  }
}

