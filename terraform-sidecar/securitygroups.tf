# Security groups

# Security Group associated with VPC subnet 
# Currently allowing port 80, 8080 , 22 for stage "deployment" which should not be done in "production". Only traffic from LB should be allowed.

resource "aws_security_group" "echoserverPubSubnetSG" {
    name = "echoserverPubSubnetSG"
    description = "Public access security group"
    vpc_id = "${aws_vpc.echoserverVPC.id}"

   ingress {
       from_port = 22
       to_port = 22
       protocol = "tcp"
       cidr_blocks = [
          "0.0.0.0/0"]
   }

   ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
   }

   ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
    }

   ingress {
      from_port = 0
      to_port = 0
      protocol = "tcp"
      cidr_blocks = [  "10.0.1.0/24"]
    }

    egress {
        # allow all egress traffic
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = [
            "0.0.0.0/0"]
    }

  
}


# Security group to be used for load balancer

resource "aws_security_group" "echoserverLBSG" {
    name = "echoserverLBSG"
    description = "LB security group"
    vpc_id = "${aws_vpc.echoserverVPC.id}"

   ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
   }

   ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = [
          "0.0.0.0/0"]
   }

   ingress {
      from_port = 0
      to_port = 0
      protocol = "tcp"
      cidr_blocks = [  "10.0.1.0/24"]
    }

    egress {
        # allow all egress
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = [
            "0.0.0.0/0"]
    }


}

