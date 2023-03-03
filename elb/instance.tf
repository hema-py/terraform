#Create the first instance

resource "aws_instance" "first-instance" {
 ami  =    "ami-0beaa649c482330f7"
 instance_type = "t2.micro"
 key_name = "demo1key" 
 security_groups = ["elb-sg"]
 user_data       = "#!/bin/bash\napt-get update\napt-get -y install net-tools nginx\nMYIP=`ifconfig | grep -E '(inet 10)|(addr:10)' | awk '{ print $2 }' | cut -d ':' -f2`\necho 'this is: '$MYIP > /var/www/html/index.html" 
 tags = {
 Name = "First_web_server"
 Source = "terraform"
 }
}

#Create the second instance

resource "aws_instance" "second-instance" {
 ami  =    "ami-0beaa649c482330f7" 
 instance_type = "t2.micro"    
 key_name = "demo1key" 
 security_groups = ["elb-sg"]
 user_data       = "#!/bin/bash\napt-get update\napt-get -y install net-tools nginx\nMYIP=`ifconfig | grep -E '(inet 10)|(addr:10)' | awk '{ print $2 }' | cut -d ':' -f2`\necho 'this is: '$MYIP > /var/www/html/index.html"
 tags = { 
   Name = "Second_web_server" 
   Source = "terraform" 
  }
}
