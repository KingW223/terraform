provider "aws" {
  region = "us-west-2"
}

# -------------------
# VPC
# -------------------
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "TF-VPC"
  }
}

# -------------------
# Subnet
# -------------------
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "TF-Subnet"
  }
}

# -------------------
# Internet Gateway
# -------------------
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "TF-IGW"
  }
}

# -------------------
# Route Table
# -------------------
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "TF-RouteTable"
  }
}

# Association Subnet -> Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# -------------------
# Security Group
# -------------------
resource "aws_security_group" "my_sg" {
  name        = "tf-security-group"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TF-SG"
  }
}

# -------------------
# EC2 Instance
# -------------------
resource "aws_instance" "foo" {
  ami                         = "ami-0e1d35993cb249cee" # us-west-2
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_subnet.id
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "TF-Instance"
  }
}


