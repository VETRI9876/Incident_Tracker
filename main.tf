provider "aws" {
  region = "eu-north-1"
}

# VPC
resource "aws_vpc" "incident_tracker_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "incident_tracker_subnet_1" {
  vpc_id                  = aws_vpc.incident_tracker_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "incident_tracker_subnet_2" {
  vpc_id                  = aws_vpc.incident_tracker_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "incident_tracker_igw" {
  vpc_id = aws_vpc.incident_tracker_vpc.id
}

# Route Table
resource "aws_route_table" "incident_tracker_rt" {
  vpc_id = aws_vpc.incident_tracker_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.incident_tracker_igw.id
  }
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.incident_tracker_subnet_1.id
  route_table_id = aws_route_table.incident_tracker_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.incident_tracker_subnet_2.id
  route_table_id = aws_route_table.incident_tracker_rt.id
}

# Security Group
resource "aws_security_group" "incident_tracker_sg" {
  vpc_id = aws_vpc.incident_tracker_vpc.id

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

# ECS Cluster
resource "aws_ecs_cluster" "incident_tracker_cluster" {
  name = "incident-tracker-cluster"
}

# Task Definition
resource "aws_ecs_task_definition" "incident_tracker_task" {
  family                   = "incident-tracker-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "incident-tracker-container"
    image     = "ghcr.io/vetri9876/incident-tracker:latest"
    essential = true
    portMappings = [{
      containerPort = 8501
      hostPort      = 8501
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "AWS_ACCESS_KEY_ID"
        value = var.AWS_ACCESS_KEY_ID
      },
      {
        name  = "AWS_SECRET_ACCESS_KEY"
        value = var.AWS_SECRET_ACCESS_KEY
      }
    ]
  }])
}

# Application Load Balancer
resource "aws_lb" "incident_tracker_alb" {
  name               = "incident-tracker-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.incident_tracker_sg.id]
  subnets = [
    aws_subnet.incident_tracker_subnet_1.id,
    aws_subnet.incident_tracker_subnet_2.id
  ]
  enable_deletion_protection = false
}

# Target Group with IP mode
resource "aws_lb_target_group" "incident_tracker_tg" {
  name        = "incident-tracker-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.incident_tracker_vpc.id
  target_type = "ip"
}

# Listener
resource "aws_lb_listener" "incident_tracker_listener" {
  load_balancer_arn = aws_lb.incident_tracker_alb.arn
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.incident_tracker_tg.arn
  }
}

# ECS Service
resource "aws_ecs_service" "incident_tracker_service" {
  name            = "incident-tracker-service"
  cluster         = aws_ecs_cluster.incident_tracker_cluster.id
  task_definition = aws_ecs_task_definition.incident_tracker_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.incident_tracker_subnet_1.id,
      aws_subnet.incident_tracker_subnet_2.id
    ]
    security_groups  = [aws_security_group.incident_tracker_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.incident_tracker_tg.arn
    container_name   = "incident-tracker-container"
    container_port   = 8501
  }

  depends_on = [aws_lb_listener.incident_tracker_listener]
}

# Output ALB URL
output "alb_url" {
  value = aws_lb.incident_tracker_alb.dns_name
}

