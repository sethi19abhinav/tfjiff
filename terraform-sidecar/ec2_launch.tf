# Launching containers on Ec2 instead of FARGATE. Fargate sounds simpler. However it is a black box . 
# Launching services on Ec2 allows better understanding of environment as well as troubleshoot any issues until its done

resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "ecs-launch-configuration"
    image_id                    = "ami-a1f8dfd9"
    instance_type               = "t2.large"
    iam_instance_profile        = "${aws_iam_instance_profile.ecs-instance-profile.id}"

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = ["${aws_security_group.echoserverPubSubnetSG.id}"]
    associate_public_ip_address = "true"
    key_name                    = "${var.ecs_key_pair_name}"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
                                  echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
                                  EOF
}



resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name                        = "ecs-autoscaling-group"
    max_size                    = "${var.max_instance_size}"
    min_size                    = "${var.min_instance_size}"
    desired_capacity            = "${var.desired_capacity}"
    vpc_zone_identifier         = ["${aws_subnet.echoserverPubSubnet.id}"]
    launch_configuration        = "${aws_launch_configuration.ecs-launch-configuration.name}"
  }

resource "aws_launch_template" "ecs-launch-configuration" {
  name_prefix = "ecs-launch-configuration"
  image_id = "ami-a1f8dfd9"
  instance_type = "t2.large"
}

