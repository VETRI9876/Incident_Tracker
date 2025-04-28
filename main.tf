provider "aws" {
  region = "eu-north-1"
}

# IAM role for ECS tasks to pull images from ECR
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the necessary policies to allow pulling from ECR
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "vetri-cluster"
}

# ECS Task Definition for your container
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "vetri-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  container_definitions = jsonencode([{
    name      = "vetri-container"
    image     = "409784048198.dkr.ecr.eu-north-1.amazonaws.com/vetri:latest"
    essential = true
    portMappings = [
      {
        containerPort = 8501
        hostPort      = 8501
        protocol      = "tcp"
      }
    ]
  }])
}

# Create a security group to allow traffic on port 8501 (for Streamlit)
resource "aws_security_group" "allow_http" {
  name        = "allow-http"
  description = "Allow HTTP traffic"
  vpc_id      = "vpc-0538e500376698a8e" # Your VPC ID

  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Application Load Balancer
resource "aws_lb" "streamlit_alb" {
  name               = "vetri-streamlit-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [
    "subnet-027c0e4750b6b7448", 
    "subnet-095a59348e8a09cce", 
    "subnet-032e1049d7bfce000"
  ]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}

# Create an ALB listener on port 80
resource "aws_lb_listener" "streamlit_listener" {
  load_balancer_arn = aws_lb.streamlit_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "Streamlit Application"
    }
  }
}

# ECS Service with Load Balancer integration
resource "aws_ecs_service" "ecs_service" {
  name            = "vetri-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [
      "subnet-027c0e4750b6b7448", 
      "subnet-095a59348e8a09cce", 
      "subnet-032e1049d7bfce000"
    ] # Your subnet IDs
    security_groups  = [aws_security_group.allow_http.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.streamlit_target_group.arn
    container_name   = "vetri-container"
    container_port   = 8501
  }
}

# Create a target group for ALB
resource "aws_lb_target_group" "streamlit_target_group" {
  name        = "vetri-target-group"
  port        = 8501
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-0538e500376698a8e" 
}

# Outputs for ECS service and ALB URL
output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}

output "alb_url" {
  value = aws_lb.streamlit_alb.dns_name
}
