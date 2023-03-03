resource "aws_instance" "demo-EC2" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
  tags = {
    Name = "MY-VPC"
  }

  # the VPC subnet
  subnet_id = aws_subnet.myvpc-public-subnet.id 

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  user_data = <<EOF
    #! /bin/bash
             sudo yum update
             sudo yum install python3 -y
             sudo yum install python3-pip -y
             /*virtualenv -p /usr/bin/python3 venv # create new virtual environment venv
             source venv/bin/activate # activate venv
             pip3 install -r requirements.txt # installs python packages
             python3 manage.py # visit app at http://localhost:5000/ping
             deactivate # deactivates venv*/
             sudo pip3 install flask
             sudo amazon-linux-extras install nginx1 -y 
             sudo mkdir flask
             sudo cd flask/
      EOF


  provisioner "file" {
    source      = "./app.py"
    destination = "/home/ec2-user/app.py"
  }

 connection {
   type        = "ssh"
   host        = self.public_ip
   user        = "ec2-user"
   private_key = file("./mykeypair")
   timeout     = "10m"
 }
}

