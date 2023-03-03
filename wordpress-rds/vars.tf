# key variable for refrencing
variable "key_name" {
  default = "wpkey"
}

# base_path for refrencing
variable "base_path" {
  default = "/root/terra/elb/"
}


variable "region" {
  description = "AWS region for hosting our your network"
  default = "us-east-1"
}

variable ami {
  default = "ami-048ff3da02834afdc"
}

variable instance_type {
  default = "t2.micro"
}

variable all {
  default = "-1"
}

variable all_cidr{
  default = "0.0.0.0/0"
}

variable tcp{
  default = "tcp"
}

variable ssh{
  default = "22"
}

variable port{
  default = 0
}

variable vpc_cidr{
  default = "192.168.0.0/16"
}

variable pub{
  default = "192.168.1.0/24"
}

variable public1 {
  default = "192.168.111.0/24"
}

variable private {
  default = "192.168.32.0/24"
}

variable private1{
  default = "192.168.222.0/24"
}

