provider "aws" {
  region = "eu-north-1"
}

# Create a security group to allow HTTP traffic
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instance and install Docker & AWS CLI
resource "aws_instance" "app_instance" {
  ami           = "ami-0c1ac8a41498c1a9c"  # Replace with your specific Ubuntu AMI ID
  instance_type = "t2.micro"
  key_name      = "devops"  # Replace with your EC2 key pair name for SSH access

  security_groups = [aws_security_group.allow_http.name]

  # Install Docker, AWS CLI, and run Docker container
  user_data = <<-EOF
              #!/bin/bash
              # Update and install necessary dependencies
              sudo apt-get update -y
              sudo apt-get install -y docker.io awscli

              # Start and enable Docker service
              sudo systemctl start docker
              sudo systemctl enable docker

              # ECR login and pull the Docker image
              sudo aws ecr get-login-password --region eu-north-1 | sudo docker login --username AWS --password-stdin 409784048198.dkr.ecr.eu-north-1.amazonaws.com

              # Pull the Docker image from ECR
              sudo docker pull 409784048198.dkr.ecr.eu-north-1.amazonaws.com/vetri:latest

              # Run the Docker container
              sudo docker run -d -p 80:8501 409784048198.dkr.ecr.eu-north-1.amazonaws.com/vetri:latest
              EOF

  tags = {
    Name = "devops-incident-tracker-instance"
  }
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  value = aws_instance.app_instance.public_ip
}
