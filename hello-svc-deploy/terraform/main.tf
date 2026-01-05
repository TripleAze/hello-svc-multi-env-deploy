terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "hello-svc-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "hello-svc-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "hello-svc-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "hello-svc-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "hello_svc" {
  name        = "hello-svc-sg"
  description = "Security group for hello-svc"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["102.215.57.40/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hello-svc-sg"
  }
}

# Production Instance
resource "aws_instance" "production" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.hello_svc.id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/../scripts/setup-instance.sh", {
    environment = "production"
    domain      = "production.${var.domain_name}"
  })

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name        = "production-hello-svc"
    Environment = "production"
  }
}

# Staging Instance
resource "aws_instance" "staging" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.hello_svc.id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/../scripts/setup-instance.sh", {
    environment = "staging"
    domain      = "staging.${var.domain_name}"
  })

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name        = "staging-hello-svc"
    Environment = "staging"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "production" {
  name              = "/aws/ec2/production-hello-svc"
  retention_in_days = 7

  tags = {
    Environment = "production"
  }
}

resource "aws_cloudwatch_log_group" "staging" {
  name              = "/aws/ec2/staging-hello-svc"
  retention_in_days = 7

  tags = {
    Environment = "staging"
  }
}
