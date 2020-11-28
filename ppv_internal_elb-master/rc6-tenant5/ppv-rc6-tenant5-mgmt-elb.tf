# Create a new load balancer

resource "aws_elb" "ppv-rc6-tenant5-mgmt-elb" {
  name               = "ppv-rc6-tenant5-mgmt-elb"
  subnets = ["subnet-62ae184d", "subnet-28842f75"]
  internal = "true"
  security_groups = ["sg-48b6972e"]

  listener {
    instance_port     = 80
    instance_protocol = "TCP"
    lb_port           = 80
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 8080
    instance_protocol = "TCP"
    lb_port           = 8080
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 3000
    instance_protocol = "TCP"
    lb_port           = 3000
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 10205
    instance_protocol = "TCP"
    lb_port           = 10205
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:80"
    interval            = 30
  }

  tags = {
    Name = "ppv-rc6-tenant5-mgmt-elb"
    Solution = "Periscope"
    Billing = "periscope-suite"
    Application = "Periscope Suite"
    Tenant = "tenant5"
    Environment = "rc6-tenant5"
  }
}