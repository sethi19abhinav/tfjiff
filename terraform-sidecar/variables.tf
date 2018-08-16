
# AWS REGION SPECIFIC 

variable "aws_region" {
	description = "Region where to setup resources"
	default = "us-west-2"
}

variable "ecs_key_pair_name" {
  description = "EC2 instance key pair name"
}


variable "ecs_cluster" {
  description = "ECS cluster name"
}

variable "aws_access_key" {
  description = "AWS access key"
}

variable "aws_secret_key" {
  description = "AWS secret access key"
}


# AWS ECS SPECIFIC

variable "es_task_cpu" {
  description = "Task CPU units to provision for Echoserver Webapp"
  default     = "1024"
}

variable "es_task_memory" {
  description = "Task memory to provision for Echoserver Webapp ( in MB)"
  default     = "2048"
}

variable "es_webapp_port" {
	description = "Port expose by container"
} 
variable "es_webapp_count" {
	description = "No. of instances of webapps to run"
	default = "1" 
}

variable "es_service_count" {
  description = "No. of echoserver services to run"
}

variable "es_max_autoscale_count" {
  description = "Max services for app Echoserver in Autoscale group"
}

variable "es_min_autoscale_count" {
  description = "Min services for app Echoserver in AutoScale group"
}

# ECS vars for service proxy 

variable "px_service_count" {
  description = "No. of proxy services to run"
}

variable "px_max_autoscale_count" {
  description = "Max services for app proxy in Autoscale group"
}

variable "px_min_autoscale_count" {
  description = "Min services for app proxy in AutoScale group"
}

# ECS vars for service proxySSL

variable "pxssl_service_count" {
  description = "No. of proxyssl services to run"
}

variable "pxssl_max_autoscale_count" {
  description = "Max services for app proxyssl in Autoscale group"
}

variable "pxssl_min_autoscale_count" {
  description = "Min services for app proxyssl in AutoScale group"
}




variable "max_instance_size" {
  description = "Maximum number of instances in the cluster"
}

variable "min_instance_size" {
  description = "Minimum number of instances in the cluster"
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
}

