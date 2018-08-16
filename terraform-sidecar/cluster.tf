# Defining cluster which will host our app

resource "aws_ecs_cluster" "echoserver" {
  name = "echoserver"
}

