# Will use internal route53 hosted zone record to point backend to internal NLB
# Requires explicit dependency to interNLB resource 

resource "aws_route53_zone" "backendzone" {
	  name   = "echoserver.com"
  vpc_id = "${aws_vpc.echoserverVPC.id}"
    depends_on = [
        "aws_alb.echoserverWebNLB",
  ]


}
data "aws_route53_zone" "backendzone" {
  zone_id = "${aws_route53_zone.backendzone.id}"
  private_zone = true

} 

#Creating CNAME record to internal NLB . 

resource "aws_route53_record" "proxy_backend" {
  zone_id = "${aws_route53_zone.backendzone.id}"
  name    = "backend"
  type    = "CNAME"
  ttl     = "5"
  records = ["${aws_alb.echoserverWebNLB.dns_name}"]
}
