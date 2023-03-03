resource "aws_instance" "wordpress1-ec2"{
  ami = var.ami
  instance_type = var.instance_type
  key_name = "MyServer1-keypair" 
  vpc_security_group_ids = [aws_security_group.sg-wp.id]
  subnet_id = aws_subnet.public_subnet1.id
  tags = {
      Name = "wordpress1-ec2"
  }

     user_data = <<EOF
    #! /bin/bash
             sudo yum install httpd php php-mysql -y -q
             sudo cd /var/www/html
             echo "Welcome" > hi.html
             sudo wget https://wordpress.org/wordpress-5.1.1.tar.gz
             sudo tar -xzf wordpress-5.1.1.tar.gz
             sudo cp -r wordpress/* /var/www/html/
             sudo rm -rf wordpress
             sudo rm -rf wordpress-5.1.1.tar.gz
             sudo chmod -R 755 wp-content
             sudo chown -R apache:apache wp-content
             sudo wget https://s3.amazonaws.com/bucketforwordpresslab-donotdelete/htaccess.txt
             sudo mv htaccess.txt .htaccess
             sudo systemctl start httpd
             sudo systemctl enable httpd
      EOF
}
#==================================================================================================
# security group

resource "aws_security_group" "sg-wp" {

  name        = "sg group"
  description = "security group for wordpress"
  vpc_id      = aws_vpc.vpc.id


    ingress {
    from_port = var.port
    to_port = var.port
    protocol = var.all
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    from_port   = var.ssh
    to_port     = var.ssh
    protocol    = var.tcp
    cidr_blocks = [var.all_cidr]
  }

  ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = var.tcp
    cidr_blocks = [var.all_cidr]
  }


  egress {
    from_port   = var.port
    to_port     = var.port
    protocol    = var.all
    cidr_blocks = [var.all_cidr]
  }
}


# ec2 instance

resource "aws_instance" "wordpress2-ec2"{
  #for_each      = aws_subnet.public
  ami = var.ami
  instance_type = var.instance_type
  key_name = "MyServer1-keypair" 
  vpc_security_group_ids = [aws_security_group.sg-wp.id]
  subnet_id = aws_subnet.public_subnet.id


  tags = {
      Name = "wordpress2-ec2"
  }

  user_data = <<EOF
         #! /bin/bash
             sudo yum install httpd php php-mysql -y -q
             sudo cd /var/www/html
             echo "Welcome" > hi.html
             sudo wget https://wordpress.org/wordpress-5.1.1.tar.gz
             sudo tar -xzf wordpress-5.1.1.tar.gz
             sudo cp -r wordpress/* /var/www/html/
             sudo rm -rf wordpress
             sudo rm -rf wordpress-5.1.1.tar.gz
             sudo chmod -R 755 wp-content
             sudo chown -R apache:apache wp-content
             sudo wget https://s3.amazonaws.com/bucketforwordpresslab-donotdelete/htaccess.txt
             sudo mv htaccess.txt .htaccess
             sudo systemctl start httpd
             sudo systemctl enable httpd
      EOF

}
#===================================================================================================================
## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  vpc_id      = aws_vpc.vpc.id
  egress {
    from_port = var.port
    to_port = var.port
    protocol = var.all
    cidr_blocks = [var.all_cidr]
  }
  ingress {
    from_port = var.port
    to_port = var.port
    protocol = var.all
    cidr_blocks = [var.all_cidr]
  }
}

# Create a new load balancer
resource "aws_elb" "wpbalancer"{
  name               = "wp-elb"
  subnets = [aws_subnet.public_subnet.id, aws_subnet.public_subnet1.id ]
  security_groups = [aws_security_group.sg-wp.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 3
    target              = "HTTP:80/wp-admin/setup-config.php"
    interval            = 30
  }

  instances                   = [aws_instance.wordpress1-ec2.id, aws_instance.wordpress2-ec2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "wpbalancer"
  }
}
#==================================================================================================================================
provider "aws"{
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}
#===================================================================================================================================
resource "aws_route53_zone" "zone" {
  name =  "example.in"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zone.zone_id
  name    = "example.in"
  type    = "A"

  alias {
    name                   = aws_elb.wpbalancer.dns_name
    zone_id                = aws_elb.wpbalancer.zone_id
    evaluate_target_health = true
  }
}
#=====================================================================================================================================
resource "aws_db_parameter_group" "default" {
  name   = "rds-pg11"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "dbsubnet"
  subnet_ids = [ aws_subnet.private_subnet.id, aws_subnet.private_subnet1.id ]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "rds-security-group"
  description = "allow inbound access to the database"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = var.all
    from_port   = var.port
    to_port     = var.port
    cidr_blocks = [ var.all_cidr]
}

  egress {
    protocol    = var.all
    from_port   = var.port
    to_port     = var.port
    cidr_blocks = [ var.all_cidr ]
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  identifier           = "wordpress"
  name                 = "wordpress"
  username             = "root"
  password             = "password"
  parameter_group_name = aws_db_parameter_group.default.id
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [ aws_security_group.sg-wp.id ]
  publicly_accessible  = false
  skip_final_snapshot  = true
  multi_az             = false
}
#============================================================================================================



#vpc

resource "aws_vpc""vpc"{
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "wp_vpc"
  }
}

#public subnet

resource "aws_subnet""public_subnet"{
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pub
  availability_zone_id = "use1-az1"
  tags = {
    Name = "public_subnet"
  }

map_public_ip_on_launch = true
}

resource "aws_subnet""public_subnet1"{
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public1
  availability_zone_id = "use1-az2"
  tags = {
    Name = "public_subnet1"
  }

map_public_ip_on_launch = true
}


#private subnet

resource "aws_subnet""private_subnet"{

  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private
  availability_zone_id = "use1-az3"
  tags = {
    Name = "private_subnet"
  }
}

resource "aws_subnet""private_subnet1"{

  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private1
  availability_zone_id = "use1-az4"
  tags = {
    Name = "private_subnet1"
  }
}


#internet gateway

resource "aws_internet_gateway""mygateway"{

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet_gateway"
  }
}

#route table with target as internet gateway

resource "aws_route_table""myroute"{

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.mygateway.id
  }

  tags = {
    Name = "route_table-01"
  }
}


#associate table to public subnet

resource "aws_route_table_association""rtassociation"{
  subnet_id = aws_subnet.public_subnet.id
 # subnet_id2 = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.myroute.id
}

resource "aws_route_table_association""rtassociation1"{
  # subnet_id = aws_subnet.public_subnet1.id
  subnet_id = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.myroute.id
}


# elastic ip
resource "aws_eip" "elastic_ip" {
  vpc      = true
}

# NAT gateway
resource "aws_nat_gateway""nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# route table with target as NAT gateway
resource "aws_route_table" "NAT_route_table" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "NAT-route-table"
  }
}

# associate route table to private subnet
resource "aws_route_table_association" "associate_routetable_to_private_subnet" {

  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.NAT_route_table.id
}

