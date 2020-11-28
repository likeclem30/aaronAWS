# Create a new load balancer

resource "aws_elb" "ppv-rc6-tenant5-svc-elb" {
  name               = "ppv-rc6-tenant5-svc-elb"
  subnets = ["subnet-62ae184d", "subnet-28842f75"]
  internal = "true"
  security_groups = ["sg-48b6972e"]

  listener {
    instance_port     = 3000
    instance_protocol = "TCP"
    lb_port           = 3000
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 3001
    instance_protocol = "TCP"
    lb_port           = 3001
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 5556
    instance_protocol = "TCP"
    lb_port           = 5556
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 5557
    instance_protocol = "TCP"
    lb_port           = 5557
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 5672
    instance_protocol = "TCP"
    lb_port           = 5672
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 8001
    instance_protocol = "TCP"
    lb_port           = 8001
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 8002
    instance_protocol = "TCP"
    lb_port           = 8002
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 8003
    instance_protocol = "TCP"
    lb_port           = 8003
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 9001
    instance_protocol = "TCP"
    lb_port           = 9001
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 9002
    instance_protocol = "TCP"
    lb_port           = 9002
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 10201
    instance_protocol = "TCP"
    lb_port           = 10201
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 10202
    instance_protocol = "TCP"
    lb_port           = 10202
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 10203
    instance_protocol = "TCP"
    lb_port           = 10203
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 10204
    instance_protocol = "TCP"
    lb_port           = 10204
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 15201
    instance_protocol = "TCP"
    lb_port           = 15201
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 15205
    instance_protocol = "TCP"
    lb_port           = 15205
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 15206
    instance_protocol = "TCP"
    lb_port           = 15206
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 15207
    instance_protocol = "TCP"
    lb_port           = 15207
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 15208
    instance_protocol = "TCP"
    lb_port           = 15208
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 15209
    instance_protocol = "TCP"
    lb_port           = 15209
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 15210
    instance_protocol = "TCP"
    lb_port           = 15210
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 15672
    instance_protocol = "TCP"
    lb_port           = 15672
    lb_protocol       = "TCP"
  }




  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:9002"
    interval            = 30
  }

  tags = {
    Name = "ppv-rc6-tenant5-svc-elb"
    Solution = "Periscope"
    Billing = "periscope-suite"
    Application = "Periscope Suite"
    Tenant = "tenant5"
    Environment = "rc6-tenant5"
  }
}