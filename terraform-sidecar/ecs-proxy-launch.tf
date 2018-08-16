# Creating launch configuration to handle HTTP connector for the APP

resource "aws_ecs_task_definition" "proxy" {
  family                   = "proxy"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "${var.es_task_cpu}"
  memory                   = "${var.es_task_memory}"
  execution_role_arn       = "${aws_iam_role.ecs-service-role.arn}"
  task_role_arn            = "${aws_iam_role.ecs-service-role.arn}"
  container_definitions    = "${file("task-definitions/proxy.json")}"
}

resource "aws_ecs_service" "proxy" {
  name            = "proxy"
  cluster         = "${aws_ecs_cluster.echoserver.id}"
   task_definition = "${aws_ecs_task_definition.proxy.family}:${aws_ecs_task_definition.proxy.revision}"
  desired_count   =  "${var.px_service_count}"
   launch_type     = "EC2"
  depends_on      = ["aws_iam_role_policy.ecs-task-policy"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.echoserverProxyTG.arn}"
    container_name   = "proxy"
    container_port   = 80
  }

  network_configuration {
    security_groups = ["${aws_security_group.echoserverPubSubnetSG.id}"]
    subnets         = ["${aws_subnet.echoserverPubSubnet.id}"]
  }
  depends_on = [
                        "aws_alb_listener.echoserverWebNLB",
  ]
}

resource "aws_appautoscaling_target" "proxyASTG" {
  max_capacity       = "${var.px_max_autoscale_count}"
  min_capacity       = "${var.px_min_autoscale_count}"
  resource_id        = "service/echoserver/proxy"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = ["aws_ecs_service.proxy"]
}


resource "aws_appautoscaling_policy" "proxyASpolicy" {
  name               = "proxyASPerCPU"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/echoserver/proxy"
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

  depends_on = ["aws_appautoscaling_target.proxyASTG", "aws_route53_record.proxy_backend" ]
}
