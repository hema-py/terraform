resource "aws_security_group" "demo-public-sg" {
  vpc_id = aws_vpc.demo.id
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "demo-public-sg"
  }
}

# Security group for private subnet VPC demo

resource "aws_security_group" "demo-private-sg" {
  vpc_id = aws_vpc.demo.id
  name        ="demo-private-sg"
  description = "security group that allows ssh and all egress traffic and ingress only in 10.100.1.0/24"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.100.1.0/24"]
  }
  tags = {
    Name = "demo-private-sg"
  }
}

# Security group for vpc demo1 private

resource "aws_security_group" "demo1-sg" {
  provider             = aws.east2
  vpc_id = aws_vpc.demo1.id
  name        = "demo1-sg"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.100.2.0/24"]
  }

 ingress {
    from_port   = -1 
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.100.2.0/24"]
  }
  tags = {
    Name = "demo1-sg"
  }
}
