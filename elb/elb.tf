
#Create a new load balancer

resource "aws_elb" "my-elb" {
  name            = "my-elb"
  availability_zones  = ["us-east-2a","us-east-2b"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  # ELB attachments

  instances                   = ["${aws_instance.first-instance.id}","${aws_instance.second-instance.id}"]
  cross_zone_load_balancing   = true
  idle_timeout = 40
  tags = {
    Name = "my-elb"
  }
}

