# Create a new load balancer

resource "aws_elb" "ppv-rc6-tenant5-es-elb" {
  name               = "ppv-rc6-tenant5-es-elb"
  subnets = ["subnet-62ae184d", "subnet-28842f75"]
  internal = "true"
  security_groups = ["sg-48b6972e"]

  listener {
    instance_port     = 9200
    instance_protocol = "TCP"
    lb_port           = 9200
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:9200"
    interval            = 30
  }

  tags = {
    Name = "ppv-rc6-tenant5-es-elb"
    Solution = "Periscope"
    Billing = "periscope-suite"
    Application = "Periscope Suite"
    Tenant = "tenant5"
    Environment = "rc6-tenant5"
  }
}