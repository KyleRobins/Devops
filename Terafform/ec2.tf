# AWS Provider Configuration
provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

# SECURITY GROUP 
resource "aws_security_group" "ssh_sg" {
  name   = "ssh_sg"
  vpc_id = aws_default_vpc.default_vpc.id

  # SSH INGRESS 
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTPS   
  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "ssh_sg"
  }
}

# EC2 INSTANCE
resource "aws_instance" "webserver" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI ID
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ssh_sg.id]  # Attach the security group

  tags = {
    Name = "webserver-instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello, World!</h1>" > /var/www/html/index.html
              EOF
}

output "webserver-Public-URL" {
  value = aws_instance.webserver.public_ip
}
