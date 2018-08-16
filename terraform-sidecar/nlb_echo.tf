# Creating an internal loadbalancer which will go infront of echoservice and will serve as backend to proxy layer
# NLB will only do TCP , so will add much lesser latency compared to an ALB and will only not mess with HTTP headers 

resource "aws_alb" "echoserverWebNLB" {
  name             = "echoserverWebNLB"
  subnets          = ["${aws_subnet.echoserverPubSubnet.id}"]
  internal         = true
  security_groups  = ["${aws_security_group.echoserverLBSG.id}"]
  load_balancer_type = "network"
}

resource "aws_alb_target_group" "echoserverWebTG" {
  name        = "echoserverWebTG"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = "${aws_vpc.echoserverVPC.id}"
  target_type = "ip"

  depends_on = [
                "aws_alb.echoserverWebNLB",
  ]
}


# Redirect all HTTP traffic from the NLB to the target group
resource "aws_alb_listener" "echoserverWebHTTP" {
  load_balancer_arn = "${aws_alb.echoserverWebNLB.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.echoserverWebTG.arn}"
    type             = "forward"
  }
}
