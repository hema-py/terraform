variable "AWS_REGION" {
default = "us-east-1"  
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}

/*variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-0b0dcb5067f052a63"
    us-east-2 = "ami-0beaa649c482330f7"
  }
}*/

