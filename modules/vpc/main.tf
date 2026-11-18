# ==============================================================================
# VPC MODULE - MAIN CONFIGURATION
# ==============================================================================
# This module creates:
# 1. A Virtual Private Cloud (VPC)
# 2. An Internet Gateway for internet access
# 3. Three public subnets across three different Availability Zones (AZs)
# 4. A public route table routing internet-bound traffic (0.0.0.0/0) to the IGW
# 5. Associations linking the three public subnets to the route table
# ==============================================================================

# Fetch list of available AWS Availability Zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# 1. Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 2. Internet Gateway (IGW) - allows communication between the VPC and the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 3. Public Subnets (3 subnets, each placed in a distinct Availability Zone)
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 4. Route Table for public subnets with default route to the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# 5. Route Table Associations (connects each public subnet to the public route table)
resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 6. ECS Application Security Group (allows inbound traffic on container_port from anywhere)
resource "aws_security_group" "app" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Security group for ECS tasks allowing inbound traffic on container port"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow inbound traffic on container port from anywhere"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

