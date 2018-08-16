# Defining Echoserver service to run webapp

resource "aws_ecs_task_definition" "echoserver" {
  family                   = "echoserver"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "${var.es_task_cpu}"
  memory                   = "${var.es_task_memory}"
  execution_role_arn       = "${aws_iam_role.ecs-service-role.arn}"
  task_role_arn            = "${aws_iam_role.ecs-service-role.arn}"
  container_definitions    = "${file("task-definitions/echo.json")}"

}


resource "aws_ecs_service" "echoserver" {
  name            = "echoserver"
  cluster         = "${aws_ecs_cluster.echoserver.id}"
  task_definition = "${aws_ecs_task_definition.echoserver.family}:${aws_ecs_task_definition.echoserver.revision}"
  desired_count   = "${var.es_service_count}"
  launch_type     = "EC2"
  depends_on      = ["aws_iam_role_policy.ecs-task-policy"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.echoserverWebTG.arn}"
    container_name   = "echoserver"
    container_port   = 8080
  }

  network_configuration {
    security_groups = ["${aws_security_group.echoserverPubSubnetSG.id}"]
    subnets         = ["${aws_subnet.echoserverPubSubnet.id}"]

# Public ip assignment is not supported when using Ec2 instance for conatiners. Will probably have to associate EIP
#    assign_public_ip = "true"
  }
}

resource "aws_appautoscaling_target" "echoserverASTG" {
  max_capacity       = "${var.es_max_autoscale_count}"
  min_capacity       = "${var.es_min_autoscale_count}"
  resource_id        = "service/echoserver/echoserver"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = ["aws_ecs_service.echoserver"]
}

resource "aws_appautoscaling_policy" "echoserverASpolicy" {
  name               = "echoserverASPerCPU"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/echoserver/echoserver"
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

# Had to explicitly define dependency on route53 backend , else proxy does not register backends . 
  depends_on = ["aws_appautoscaling_target.echoserverASTG", "aws_route53_record.proxy_backend" ]
}

