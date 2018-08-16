aws_access_key = ""
aws_secret_key = ""

aws_region = "us-west-2"
ecs_key_pair_name = "abhinav-key"
ecs_cluster = "echoserver"
max_instance_size = 3
min_instance_size = 2
desired_capacity = 2





es_webapp_image = "958322632608.dkr.ecr.us-west-2.amazonaws.com/echoserver:latest"
es_webapp_cn_port = 8080
es_webapp_host_port = 8080
es_webapp_port = 8080

# Echoserver ECS vars
es_service_count = 1
es_max_autoscale_count = 3
es_min_autoscale_count = 1

# Proxy ECS vars 
px_service_count = 1
px_max_autoscale_count = 3
px_min_autoscale_count = 1

# ProxySSL ECS vars
pxssl_service_count = 1
pxssl_max_autoscale_count = 3
pxssl_min_autoscale_count = 1
