terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.13.5"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-west-2a"

  tags = {
    Name = "Default subnet for us-west-2a"
  }
}

resource "aws_security_group" "prod-web-servers-sg" {
  name        = "prod-web-servers-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_default_vpc.default.cidr_block]
    
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_default_vpc.default.cidr_block]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "prod-web-servers-sg"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "prod-web-server-1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.large"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.prod-web-servers-sg.id]

  tags = {
    Name = " prod-web-server-1"
  }
}

resource "aws_instance" "prod-web-server-2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.large"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.prod-web-servers-sg.id]
  tags = {
    Name = " prod-web-server-2"
  }

}

resource "aws_lb" "network-lb" {
  name               = "network-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_default_subnet.default_az1.id] 

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "network-lb-tg" {
  name     = "network-lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_default_vpc.default.id
}

resource "aws_lb_target_group_attachment" "network-lb-tg-register-1" {
  target_group_arn = aws_lb_target_group.network-lb-tg.arn
  target_id        = aws_instance.prod-web-server-1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "network-lb-tg-register-2" {
  target_group_arn = aws_lb_target_group.network-lb-tg.arn
  target_id        = aws_instance.prod-web-server-2.id
  port             = 80
}


resource "aws_lb_listener" "network-lb-listener" {
  load_balancer_arn = aws_lb.network-lb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.network-lb-tg.arn
  }
}

resource "aws_lb_listener" "network-lb-listener-443" {
  load_balancer_arn = aws_lb.network-lb.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = "arn:aws:acm:us-west-2:212374997444:certificate/b40185b5-4771-4b60-8330-e5b63f6f77df" # Created my own certificate and provided ARN
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.network-lb-tg.arn
  }
}