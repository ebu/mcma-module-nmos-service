###############################
# VPC + default security group
###############################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true

  tags = {
    Name = var.global_prefix
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.global_prefix}-default"
  }
}

##################################
# public subnet
####################################

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "${var.global_prefix}-public"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.global_prefix
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = {
    Name = "${var.global_prefix}-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.global_prefix}-public-ip"
  }
}

resource "aws_nat_gateway" "gw" {
  depends_on = [aws_internet_gateway.public]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.global_prefix}-nat"
  }
}

################################
# private subnet
################################

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "${var.global_prefix}-private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "${var.global_prefix}-private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

################################
# DHCP
##############################

locals {
  dns_ip_address  = "10.0.1.10"
  rds_ip_address =  "10.0.1.11"
  dns_domain_name = "mcma-nmos.io"
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name         = local.dns_domain_name
  domain_name_servers = [local.dns_ip_address, "1.1.1.1"]

  tags = {
    Name = var.global_prefix
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

################################
# key pair for connecting to EC2 instances
##############################

resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2" {
  key_name   = "${var.global_prefix}-ec2"
  public_key = tls_private_key.ec2.public_key_openssh
}

##################################
# ECS
##################################

resource "aws_ecs_cluster" "main" {
  name = var.global_prefix
}

resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.main.id
  name = "${var.global_prefix}-ecs"

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.global_prefix}-ecs"
  }
}
