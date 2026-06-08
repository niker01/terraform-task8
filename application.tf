locals {
  common_tags = {
    Terraform = "true"
    Project   = var.project_name
  }
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name = "cidr-block"
    values = [
      var.public_subnet_a_cidr,
      var.public_subnet_b_cidr
    ]
  }
}

data "aws_security_group" "ec2" {
  filter {
    name   = "group-name"
    values = [var.ec2_sg_name]
  }
}

data "aws_security_group" "http" {
  filter {
    name   = "group-name"
    values = [var.http_sg_name]
  }
}

data "aws_security_group" "alb" {
  filter {
    name   = "group-name"
    values = [var.alb_sg_name]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "this" {
  name          = var.launch_template_name
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    delete_on_termination = true

    security_groups = [
      data.aws_security_group.ec2.id,
      data.aws_security_group.http.id
    ]
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
dnf update -y
dnf install -y httpd jq
systemctl enable httpd
systemctl start httpd

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
-s http://169.254.169.254/latest/meta-data/instance-id)

PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
-s http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<HTML > /var/www/html/index.html
<html>
<body>
<h1>Instance ID: $INSTANCE_ID</h1>
<h2>Private IP: $PRIVATE_IP</h2>
</body>
</html>
HTML
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }

  tags = local.common_tags
}

resource "aws_lb" "this" {
  name               = var.alb_name
  load_balancer_type = "application"

  security_groups = [
    data.aws_security_group.alb.id
  ]

  subnets = data.aws_subnets.public.ids

  tags = local.common_tags
}

resource "aws_lb_target_group" "this" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    path = "/"
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_autoscaling_group" "this" {
  name             = var.asg_name
  desired_capacity = 2
  min_size         = 1
  max_size         = 2

  vpc_zone_identifier = data.aws_subnets.public.ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns
    ]
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = aws_lb_target_group.this.arn
}