variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "launch_template_name" {
  description = "Launch template name"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
}

variable "alb_name" {
  description = "Application Load Balancer name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "Public subnet A CIDR"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "Public subnet B CIDR"
  type        = string
}

variable "ec2_sg_name" {
  description = "EC2 SSH security group"
  type        = string
}

variable "http_sg_name" {
  description = "EC2 HTTP security group"
  type        = string
}

variable "alb_sg_name" {
  description = "ALB security group"
  type        = string
}