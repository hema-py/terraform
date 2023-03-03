# Internet VPC
resource "aws_vpc" "MY-VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "MY-VPC"
  }
}

# Subnets
resource "aws_subnet" "myvpc-public-subnet" {
  vpc_id                  = aws_vpc.MY-VPC.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "myvpc-public-subnet"
  }
}

resource "aws_subnet" "myvpc-private-subnet" {
  vpc_id                  = aws_vpc.MY-VPC.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "myvpc-private-subnet"
  }
}

# Internet GW
resource "aws_internet_gateway" "myvpc-igw" {
  vpc_id = aws_vpc.MY-VPC.id

  tags = {
    Name = "MY-VPC"
  }
}

# route tables
resource "aws_route_table" "myvpc-public" {
  vpc_id = aws_vpc.MY-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myvpc-igw.id
  }

  tags = {
    Name = "myvpc-public-subnet"
  }
}

# route associations public
resource "aws_route_table_association" "myvpc-public-subnet-a" {
  subnet_id      = aws_subnet.myvpc-public-subnet.id
  route_table_id = aws_route_table.myvpc-public.id
}


