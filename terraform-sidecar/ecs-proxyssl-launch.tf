#Launch configuration for proxyssl which will do SSL termination


resource "aws_ecs_task_definition" "proxyssl" {
  family                   = "proxyssl"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "${var.es_task_cpu}"
  memory                   = "${var.es_task_memory}"
  execution_role_arn       = "${aws_iam_role.ecs-service-role.arn}"
  task_role_arn            = "${aws_iam_role.ecs-service-role.arn}"
  container_definitions    = "${file("task-definitions/proxyssl.json")}"
}

resource "aws_ecs_service" "proxyssl" {
  name            = "proxyssl"
  cluster         = "${aws_ecs_cluster.echoserver.id}"
   task_definition = "${aws_ecs_task_definition.proxyssl.family}:${aws_ecs_task_definition.proxyssl.revision}"
  desired_count   =  "${var.pxssl_service_count}"
   launch_type     = "EC2"
  depends_on      = ["aws_iam_role_policy.ecs-task-policy"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.echoserverProxyTGSSL.arn}"
    container_name   = "proxyssl"
    container_port   = 443
  }

  network_configuration {
    security_groups = ["${aws_security_group.echoserverPubSubnetSG.id}"]
    subnets         = ["${aws_subnet.echoserverPubSubnet.id}"]
  }
  depends_on = [
                        "aws_alb_listener.echoserverWebNLB",
  ]
}

resource "aws_appautoscaling_target" "proxyASTGSSL" {
  max_capacity       = "${var.px_max_autoscale_count}"
  min_capacity       = "${var.px_min_autoscale_count}"
  resource_id        = "service/echoserver/proxyssl"
#  role_arn           = "${aws_iam_role.ecs_service_role.id}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = ["aws_ecs_service.proxyssl"]
}


resource "aws_appautoscaling_policy" "proxyASSSLpolicy" {
  name               = "proxyASPerCPU"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/echoserver/proxyssl"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value       = "70"
    scale_in_cooldown  = "300"
    scale_out_cooldown = "300"

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = ["aws_appautoscaling_target.proxyASTGSSL", "aws_route53_record.proxy_backend" ]
}
