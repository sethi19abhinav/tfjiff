# Network.tf 


# Create a VPC with single subnet so we have a flat network which simplifies deployment of micro services.
# VPC , Route table entries , Internet Gateway will be defined here. 
# Java app name "echoserver"

# VPC that hosts the project EchoServer
resource "aws_vpc" "echoserverVPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags {
    Name = "EchoServer"
	Project = "EchoWeb"
	Owner = "Abhinav"
	Stage = "Test"
  }
}


# Public Subnet

resource "aws_subnet" "echoserverPubSubnet" {
  vpc_id = "${aws_vpc.echoserverVPC.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags {
    Name = "EchoServerPubSubnet"
	Project = "EchoWeb"
	Owner = "Abhinav"
	Stage = "Test"
  }
}

# Internet gateway for Public Subnet
resource "aws_internet_gateway" "echoserverPubSubnetGW" {
  vpc_id = "${aws_vpc.echoserverVPC.id}"
  tags {
    Name = "EchoServerGW"
	Project = "EchoWeb"
	Owner = "Abhinav"
	Stage = "Test"
  }
}

# Routing table for Public Subnet
resource "aws_route_table" "echoserverPubSubnetRT" {
  vpc_id = "${aws_vpc.echoserverVPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.echoserverPubSubnetGW.id}"
  }
  tags {
    Name = "EchoServerPubSubnetRT"
	Project = "EchoWeb"
	Owner = "Abhinav"
	Stage = "Test"
  }
}

# Link Routing table to Public Subnet
resource "aws_route_table_association" "echoserverPubSubnetRTLink" {
  subnet_id = "${aws_subnet.echoserverPubSubnet.id}"
  route_table_id = "${aws_route_table.echoserverPubSubnetRT.id}"
}
