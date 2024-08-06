provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Public Subnets
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_az3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

# Private Subnets
resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private_subnet_az3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1c"
}

# Data Subnets
resource "aws_subnet" "data_subnet_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "data_subnet_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "data_subnet_az3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1c"
}

# NAT Gateways
resource "aws_nat_gateway" "nat_gw_az1" {
  allocation_id = aws_eip.nat_eip_az1.id
  subnet_id     = aws_subnet.public_subnet_az1.id
}

resource "aws_nat_gateway" "nat_gw_az2" {
  allocation_id = aws_eip.nat_eip_az2.id
  subnet_id     = aws_subnet.public_subnet_az2.id
}

resource "aws_nat_gateway" "nat_gw_az3" {
  allocation_id = aws_eip.nat_eip_az3.id
  subnet_id     = aws_subnet.public_subnet_az3.id
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip_az1" {
  vpc   = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "nat_eip_az2" {
  vpc   = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "nat_eip_az3" {
  vpc   = true
  depends_on = [aws_internet_gateway.gw]
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "private_rt_az1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az1.id
  }
}

resource "aws_route_table" "private_rt_az2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az2.id
  }
}

resource "aws_route_table" "private_rt_az3" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_az3.id
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_subnet_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_az3" {
  subnet_id      = aws_subnet.public_subnet_az3.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_az1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_rt_az1.id
}

resource "aws_route_table_association" "private_subnet_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_rt_az2.id
}

resource "aws_route_table_association" "private_subnet_az3" {
  subnet_id      = aws_subnet.private_subnet_az3.id
  route_table_id = aws_route_table.private_rt_az3.id
}

# Security Group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "public_ec2_az1" {
  ami           = "ami-0cff7528ff583bf9a" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_az1.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  associate_public_ip_address = true

  tags = {
    Name = "Public EC2 Instance AZ1"
  }
}

resource "aws_instance" "public_ec2_az2" {
  ami           = "ami-0cff7528ff583bf9a" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_az2.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  associate_public_ip_address = true

  tags = {
    Name = "Public EC2 Instance AZ2"
  }
}

resource "aws_instance" "public_ec2_az3" {
  ami           = "ami-0cff7528ff583bf9a" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_az3.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  associate_public_ip_address = true

  tags = {
    Name = "Public EC2 Instance AZ3"
  }
}