# Creating NLB to interface with Proxy
# a scalable TCP load balancer allows us to scale SSL termination layer and HTTP layer easily 

resource "aws_alb" "echoserverProxyNLB" {
  name            = "echoserverProxyNLB"
  subnets         = ["${aws_subnet.echoserverPubSubnet.id}"]
  internal = false 
  load_balancer_type = "network"
}

resource "aws_alb_target_group" "echoserverProxyTG" {
  name        = "echoserverProxyTG"
  port        = 80
  protocol    = "TCP"
  vpc_id      = "${aws_vpc.echoserverVPC.id}"
  target_type = "ip"

  depends_on = [
		"aws_alb.echoserverProxyNLB",
  ]
}

# We will need another target group to handle SSL traffic 
resource "aws_alb_target_group" "echoserverProxyTGSSL" {
  name        = "echoserverProxyTGSSL"
  port        = 443
  protocol    = "TCP"
  vpc_id      = "${aws_vpc.echoserverVPC.id}"
  target_type = "ip"
  depends_on = [
               "aws_alb.echoserverProxyNLB",
  ]
}


# Redirect all HTTP traffic from the NLB to the target group
resource "aws_alb_listener" "echoserverProxyNLBHTTP" {
  load_balancer_arn = "${aws_alb.echoserverProxyNLB.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.echoserverProxyTG.arn}"
    type             = "forward"
  }
}

# Redirect all HTTPs traffic from the NLB to the target group
resource "aws_alb_listener" "echoserverProxyNLBHTTPS" {
  load_balancer_arn = "${aws_alb.echoserverProxyNLB.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.echoserverProxyTGSSL.arn}"
    type             = "forward"
  }
}
