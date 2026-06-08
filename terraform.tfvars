aws_region = "eu-west-1"

project_name = "cmtr-xpj56jfp"

launch_template_name = "cmtr-xpj56jfp-template"
asg_name             = "cmtr-xpj56jfp-asg"
alb_name             = "cmtr-xpj56jfp-loadbalancer"

instance_type = "t3.micro"

key_name              = "cmtr-xpj56jfp-keypair"
instance_profile_name = "cmtr-xpj56jfp-instance_profile"

vpc_name = "cmtr-xpj56jfp-vpc"

public_subnet_a_cidr = "10.0.1.0/24"
public_subnet_b_cidr = "10.0.3.0/24"

ec2_sg_name  = "cmtr-xpj56jfp-ec2_sg"
http_sg_name = "cmtr-xpj56jfp-http_sg"
alb_sg_name  = "cmtr-xpj56jfp-sglb"