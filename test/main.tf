```hcl
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Main VPC"
  }
}

# Public Subnets
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "public_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Public Subnet 3"
  }
}

# Private Subnets
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_subnet" "private_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Private Subnet 3"
  }
}

# Data Subnets
resource "aws_subnet" "data_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Data Subnet 1"
  }
}

resource "aws_subnet" "data_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.200.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Data Subnet 2"
  }
}

resource "aws_subnet" "data_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.300.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Data Subnet 3"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main Internet Gateway"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "NAT Gateway 1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "NAT Gateway 2"
  }
}

resource "aws_nat_gateway" "nat_3" {
  allocation_id = aws_eip.nat_3.id
  subnet_id     = aws_subnet.public_3.id

  tags = {
    Name = "NAT Gateway 3"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat_1" {
  vpc   = true
  tags = {
    Name = "NAT Gateway 1 EIP"
  }
}

resource "aws_eip" "nat_2" {
  vpc   = true
  tags = {
    Name = "NAT Gateway 2 EIP"
  }
}

resource "aws_eip" "nat_3" {
  vpc   = true
  tags = {
    Name = "NAT Gateway 3 EIP"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

  tags = {
    Name = "Private Route Table 1"
  }
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }

  tags = {
    Name = "Private Route Table 2"
  }
}

resource "aws_route_table" "private_3" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_3.id
  }

  tags = {
    Name = "Private Route Table 3"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_3" {
  subnet_id      = aws_subnet.public_3.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}

resource "aws_route_table_association" "private_3" {
  subnet_id      = aws_subnet.private_3.id
  route_table_id = aws_route_table.private_3.id
}

# Security Groups
resource "aws_security_group" "ssh_access" {
  name        = "SSH Access"
  description = "Allow SSH access"
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

  tags = {
    Name = "SSH Access"
  }
}

resource "aws_security_group" "web_access" {
  name        = "Web Access"
  description = "Allow web access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web Access"
  }
}

# Network ACLs
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Public Network ACL"
  }
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Private Network ACL"
  }
}

# Bastion Hosts
resource "aws_instance" "bastion_1" {
  ami           = "ami-0cff7528ff583bf9a" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "Bastion Host 1"
  }
}

resource "aws_instance" "bastion_2" {
  ami           = "ami-0cff7528ff583bf9a" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "Bastion Host 2"
  }
}

resource "aws_instance" "bastion_3" {
  ami           = "ami-0cff7528ff583bf9a" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_3.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "Bastion Host 3"
  }
}

# Web Servers
resource "aws_instance" "web_server_1" {
  count         = 2
  ami           = "ami-0cff7528ff583bf9a" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.web_access.id]

  tags = {
    Name = "Web Server 1-${count.index + 1}"
  }
}

resource "aws_instance" "web_server_2" {
  count         = 2
  ami           = "ami-0cff7528ff583bf9a" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_2.id
  vpc_security_group_ids = [aws_security_group.web_access.id]

  tags = {
    Name = "Web Server 2-${count.index + 1}"
  }
}

resource "aws_instance" "web_server_3" {
  count         = 2
  ami           = "ami-0cff7528ff583bf9a" # Replace with your desired AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_3.id
  vpc_security_group_ids = [aws_security_group.web_access.id]

  tags = {
    Name = "Web Server 3-${count.index + 1}"
  }
}

# Load Balancer
resource "aws_lb" "web_lb" {
  name               = "Web-LB"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id]
  security_groups    = [aws_security_group.web_access.id]
}

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
  }
}

# CloudWatch Logging
resource "aws_cloudwatch_log_group" "main" {
  name = "main-log-group"
}
```

This Terraform code creates the infrastructure as per the provided architecture diagram, including the VPC, subnets, internet gateway, NAT gateways, route tables, security groups, network ACLs, bastion hosts, web servers, load balancer, and CloudWatch log group. Please note that you will need to replace the AMI ID with the desired AMI for your instances.