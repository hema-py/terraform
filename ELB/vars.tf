variable "AWS_REGION" {
  default = "us-east-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "myec2key"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "myec2key.pub"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-0b0dcb5067f052a63"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}

