provider "aws" {
    region = "cn-northwest-1"
    profile = "fg_demo"
}
# Create VPC with CIDR: 172.31.0.0/16
resource "aws_vpc" "eks_vpc" {
    cidr_block = "172.31.0.0/16'
    tags = {
        Name = "fg_eks_vpc"
    }
}
# Create Subnet with CIDR: 172.31.2.0/24
resource "aws_subnet" "eks_subnet" {
    vpc_id = "${aws_vpc.eks_vpc.id}"
    cidr_block = "172.31.2.0/24"
    availability_zone = "cn-northwest-1a"
    tags = {
        Name = "fg_eks_subnet"
    }
}
# Create Security Group with Name: fg_eks_sg
resource "aws_security_group" "eks_sg" {
    vpc_id = "${aws_vpc.eks_vpc.id}"
    description = "fg_eks_sg"
    name = "fg_eks_sg"
    tags = {
        Name = "fg_eks_sg"
    }
}
# Create IAM Role for EKS Fargate Cluster role
resource "aws_iam_role" "eks_fargate_role" {
    name = "fg_eks_fargate_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# Create IAM Role for EKS Service Role
resource "aws_iam_role" "eks_service_role" {
    name = "fg_eks_service_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# Create EKS Cluster
resource "aws_eks_cluster" "fg_eks_cluster" {
    name = "fg_eks_cluster"
    vpc_id = "${aws_vpc.eks_vpc.id}"
    role_arn = "${aws_iam_role.eks_fargate_role.arn}"
    tags = {
        Name = "fg_eks_cluster"
    }
}
# Create Fargate profile for EKS Cluster
resource "aws_eks_fargate_profile" "fg_eks_fargate_profile" {
    cluster_name = "${aws_eks_cluster.fg_eks_cluster.name}"
    fargate_profile_name = "fg_eks_fargate_profile"
    pod_execution_role_arn = "${aws_iam_role.eks_service_role.arn}"
    selector = {
        "matchLabels": {
            "app": "fg_eks_fargate_profile"
        }
    }
    tags = {
        Name = "fg_eks_fargate_profile"
    }
}