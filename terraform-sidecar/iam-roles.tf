# Here we define all the IAM roles needed. 
# We will need an IAM role for Ec2 , Ecs , ecs tasks and may be for Lambda function depending upon the final architecture

# Define IAM role for Ec2 instances
resource "aws_iam_role" "ecs-instance-role" {
    name                = "ecs-instance-role"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
}

# Policy document . Giving extra permissions to speed up implementation. Will revoke and test before production.
data "aws_iam_policy_document" "ecs-instance-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com","ecs.amazonaws.com","ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
    role       = "${aws_iam_role.ecs-instance-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy" "ecs-instance-role-policy" {
  name = "ecs-instance-role-policy"
  role = "${aws_iam_role.ecs-instance-role.id}"

policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
 {
 "Effect": "Allow",
 "Action": [
 "ecs:CreateCluster",
 "ecs:DeregisterContainerInstance",
 "ecs:DiscoverPollEndpoint",
 "ecs:Poll",
 "ecs:RegisterContainerInstance",
 "ecs:StartTelemetrySession",
 "ecs:Submit*",
 "ecr:GetAuthorizationToken",
 "ecr:BatchCheckLayerAvailability",
 "ecr:GetDownloadUrlForLayer",
 "ecr:BatchGetImage",
 "logs:CreateLogStream",
 "logs:PutLogEvents"
 ],
 "Resource": "*"
 }
 ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile"
    path = "/"
    role = "${aws_iam_role.ecs-instance-role.id}"
    provisioner "local-exec" {
      command = "sleep 10"
    }
}
##########################################################################################

# Define ECS role

resource "aws_iam_role" "ecs-service-role" {
    name                = "ecs-service-role"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

data "aws_iam_policy_document" "ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com","ecs-tasks.amazonaws.com"]


      }
    }
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
    role       = "${aws_iam_role.ecs-service-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}


#Policy to execute ECR functions

resource "aws_iam_role_policy" "ecs-task-policy" {
  name = "ecs-task-policy"
  role = "${aws_iam_role.ecs-service-role.id}"

policy = <<EOF
{
"Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


#############################################################################3
