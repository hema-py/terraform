resource "aws_instance" "demo-EC2" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
  tags = {
    #Name = "MY-VPC"
     Name = "jenkins-server"
  }

  # the VPC subnet
  subnet_id = aws_subnet.myvpc-public-subnet.id 

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name
}

