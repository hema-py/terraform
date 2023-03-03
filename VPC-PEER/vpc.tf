provider "aws"{
   region             = "us-east-1"
}

provider "aws"{
   region             = "us-east-2"
   alias              = "east2"
}

# Create VPC in US east region

resource "aws_vpc" "demo" {
  cidr_block           = "10.100.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "demo"
  }
}

# Create a public subnet in vpc-demo

# Subnets
resource "aws_subnet" "demo-public-subnet" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = "10.100.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "demo-public-subnet"
  }
}

#Create a IGW for VPC demo

# Internet GW
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo.id
  tags = {
    Name = "demo"
  }
}

# route tables
resource "aws_route_table" "demo-public" {
  vpc_id = aws_vpc.demo.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }

  tags = {
    Name = "demo-public-subnet"
  }
}

# route associations public

resource "aws_route_table_association" "demo-public-subnet" {
  subnet_id      = aws_subnet.demo-public-subnet.id
  route_table_id = aws_route_table.demo-public.id
}

# Create a private subnet in VPC-demo

resource "aws_subnet" "demo-private-subnet" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = "10.100.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "demo-private-subnet"
  }
}

#Create a VPC in us-east-2 region

resource "aws_vpc" "demo1" {
  provider             = aws.east2
  cidr_block           = "10.200.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "demo1"
  }
}

# Create a private Subnet for VPC demo1

resource "aws_subnet" "demo1-private-subnet" {
  provider                = aws.east2
  vpc_id                  = aws_vpc.demo1.id
  cidr_block              = "10.200.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-2a"

  tags = {
    Name = "demo1-private-subnet"
  }
}

# Create Ec2 instances in VPC demo public 

resource "aws_instance" "demo-eC2-public" {
  ami           = "ami-0b0dcb5067f052a63" 
  instance_type = "t2.micro"
  tags = {
    Name = "demo-ec2-public"
  }

  # the VPC subnet
  subnet_id = aws_subnet.demo-public-subnet.id

  # the security group
  vpc_security_group_ids = [aws_security_group.demo-public-sg.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name
}

# Create a Ec2 instance in VPC demo private

resource "aws_instance" "demo-eC2-private" {
  ami           = "ami-0b0dcb5067f052a63"
  instance_type = "t2.micro"
  tags = {
    Name = "demo-ec2-private"
  }

  # the VPC subnet
  subnet_id = aws_subnet.demo-private-subnet.id

  # the security group
  vpc_security_group_ids = [aws_security_group.demo-private-sg.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name
}

# Create a Ec2 instance in VPC demo1-private

resource "aws_instance" "demo1-eC2-private" {
  provider      = aws.east2
  ami           = "ami-0beaa649c482330f7" 
  instance_type = "t2.micro"
  key_name = "demo1key"
   tags = {
    Name = "demo1-ec2-private"
  }

# the VPC subnet
  subnet_id = aws_subnet.demo1-private-subnet.id
# the security group
  vpc_security_group_ids = [aws_security_group.demo1-sg.id]

}


resource "aws_vpc_peering_connection" "demo-demo1-vpc-peering" {
  peer_vpc_id   = aws_vpc.demo1.id 
  vpc_id        = aws_vpc.demo.id
  peer_region   = "us-east-2" 

tags = {
    Name = "demo-demo1-vpc-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "accept" {
  provider                  = aws.east2
  vpc_peering_connection_id = aws_vpc_peering_connection.demo-demo1-vpc-peering.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

# Create a route for VPC-Peering in demo

resource "aws_route" "demo2demo1" {

# ID of VPC 1 main route table.
  route_table_id = aws_vpc.demo.main_route_table_id

# CIDR block / IP range for VPC 2.
  destination_cidr_block = aws_vpc.demo1.cidr_block

  # ID of VPC peering connection.
  vpc_peering_connection_id = aws_vpc_peering_connection.demo-demo1-vpc-peering.id
}

# Create a route for VPC-Peering in demo1

resource "aws_route" "demo12demo" {

  provider                  = aws.east2
# ID of VPC demo1 main route table.
  route_table_id = aws_vpc.demo1.main_route_table_id

  # CIDR block / IP range for VPC 2.
  destination_cidr_block = aws_vpc.demo.cidr_block

  # ID of VPC peering connection.
  vpc_peering_connection_id = aws_vpc_peering_connection.demo-demo1-vpc-peering.id
}
