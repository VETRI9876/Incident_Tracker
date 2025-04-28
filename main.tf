provider "aws" {
  region = "eu-north-1"
}

# VPC Configuration
data "aws_vpc" "default" {
  id = "vpc-0538e500376698a8e"
}

# Subnet Configuration
data "aws_subnet" "subnet_1" {
  id = "subnet-027c0e4750b6b7448"
}

data "aws_subnet" "subnet_2" {
  id = "subnet-095a59348e8a09cce"
}

data "aws_subnet" "subnet_3" {
  id = "subnet-032e1049d7bfce000"
}

# Security Group
resource "aws_security_group" "allow_http" {
  name_prefix = "allow-http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"  # Corrected ARN
}

# Attach S3 Access Policy to ECS Task Execution Role
resource "aws_iam_role_policy" "ecs_task_execution_role_s3_access" {
  name   = "ecs-task-execution-role-s3-access"
  role   = aws_iam_role.ecs_task_execution_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::vetri-devops-bucket/incident_data.csv"
      }
    ]
  })
}

# Load Balancer Configuration
resource "aws_lb" "streamlit_alb" {
  name               = "streamlit-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id, data.aws_subnet.subnet_3.id]
  enable_deletion_protection = false
}

# Target Group Configuration
resource "aws_lb_target_group" "streamlit_target_group" {
  name        = "streamlit-target-group"
  port        = 8501
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    path     = "/"
    interval = 30
    timeout  = 5
  }
}

# ALB Listener Configuration
resource "aws_lb_listener" "streamlit_listener" {
  load_balancer_arn = aws_lb.streamlit_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.streamlit_target_group.arn
  }
}

# ECS Cluster Configuration
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "vetri-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "vetri-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    name      = "vetri-container"
    image     = "409784048198.dkr.ecr.eu-north-1.amazonaws.com/vetri:latest"  # Your image URI
    portMappings = [
      {
        containerPort = 8501
        hostPort      = 8501
        protocol      = "tcp"
      }
    ]
  }])

  memory     = "512"
  cpu        = "256"
}

# ECS Service Configuration
resource "aws_ecs_service" "ecs_service" {
  name            = "vetri-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [
      data.aws_subnet.subnet_1.id,
      data.aws_subnet.subnet_2.id,
      data.aws_subnet.subnet_3.id
    ]
    security_groups  = [aws_security_group.allow_http.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.streamlit_target_group.arn
    container_name   = "vetri-container"
    container_port   = 8501
  }

  depends_on = [aws_lb_listener.streamlit_listener]
}

# Output Load Balancer URL
output "load_balancer_url" {
  value = aws_lb.streamlit_alb.dns_name
}
