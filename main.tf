terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
    profile = "default"
    region = "ap-south-1"
}

# VPC
resource "aws_vpc" "myvpc" {
  cidr_block   = "10.10.0.0/16"

  tags = {
    Name = "myvpc"
  }
}

#subnet-1a
resource "aws_subnet" "Subnet_1a" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.10.5.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "subnet-1a"
  }
}

#subnet-1b
resource "aws_subnet" "Subnet_1b" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.10.6.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "subnet-1b"
  }
}




#INTERNET GATEWAY
resource "aws_internet_gateway" "myvpc_ig" {
vpc_id = aws_vpc.myvpc.id

tags = {
Name = "myvpc_ig"
}
}

#Routing Table-Public
resource "aws_route_table" "rt_public" {
vpc_id = aws_vpc.myvpc.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.myvpc_ig.id
}

tags = {
Name = "rt_public"
}
}

# Associating routing table to subnet-1a
resource "aws_route_table_association" "associate-1a-rt" {
  subnet_id      = aws_subnet.Subnet_1a.id
  route_table_id = aws_route_table.rt_public.id
}


#Security group port 80
resource "aws_security_group" "port-80" {
  vpc_id = aws_vpc.myvpc.id
  description = "default VPC security group"
  ingress {
    description      = "HTTP from ALL Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}


#Security group port 3306
resource "aws_security_group" "port-3306" {
  vpc_id = aws_vpc.myvpc.id
  description = "default VPC security group"
  ingress {
    description      = "HTTP from ALL Internet"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

#Webserver-1

resource "aws_instance" "web001" {
ami = "ami-0851b76e8b1bce90b"
instance_type = "t3.micro"
subnet_id = aws_subnet.Subnet_1a.id
vpc_security_group_ids = [aws_security_group.port-80.id]
tags = {
Name = "webserver"
Type = "Webserver"
}
}

#Webserver-2
resource "aws_instance" "web002" {
ami = "ami-0851b76e8b1bce90b"
instance_type = "t2.micro"
subnet_id = aws_subnet.Subnet_1a.id
vpc_security_group_ids = [aws_security_group.port-80.id]
tags = {
Name = "webserver"
Type = "Webserver"
}
}

#dbserver
resource "aws_instance" "db001" {
ami = "ami-0851b76e8b1bce90b"
instance_type = "t2.micro"
subnet_id = aws_subnet.Subnet_1b.id
vpc_security_group_ids = [aws_security_group.port-3306.id]
tags = {
Name = "dbserver"
Type = "database"
}
}
