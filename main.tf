provider "aws" {
  region = "eu-north-1"
}

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

resource "aws_instance" "app_instance" {
  ami           = "ami-0abcdef1234567890" # Change this to a valid AMI ID
  instance_type = "t2.micro"

  security_groups = [aws_security_group.allow_http.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo docker pull <aws_account_id>.dkr.ecr.eu-north-1.amazonaws.com/my-incident-tracker:latest
              sudo docker run -d -p 80:8501 <aws_account_id>.dkr.ecr.eu-north-1.amazonaws.com/my-incident-tracker:latest
              EOF

  tags = {
    Name = "incident-tracker-instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.app_instance.public_ip
}
