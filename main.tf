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

# Create EC2 instance and install Docker
resource "aws_instance" "app_instance" {
  ami           = "ami-0abcdef1234567890" # Replace with the correct AMI ID for your region
  instance_type = "t2.micro"
  key_name      = "my-ec2-keypair"  # Replace with your EC2 key pair name for SSH access

  security_groups = [aws_security_group.allow_http.name]

  # Install Docker, pull image from ECR, and run it
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo aws ecr get-login-password --region eu-north-1 | sudo docker login --username AWS --password-stdin 409784048198.dkr.ecr.eu-north-1.amazonaws.com
              sudo docker pull 409784048198.dkr.ecr.eu-north-1.amazonaws.com/vetri:latest
              sudo docker run -d -p 80:8501 409784048198.dkr.ecr.eu-north-1.amazonaws.com/vetri:latest
              EOF

  tags = {
    Name = "incident-tracker-instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.app_instance.public_ip
}
