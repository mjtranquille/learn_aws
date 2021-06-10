terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}
provider "aws" {
  region = "us-east-1"
  
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    
    name = var.vpc_name
    cidr = var.vpc_cidr
    azs = var.vpc_azs
    public_subnets  = var.vpc_public_subnets

    enable_nat_gateway = var.vpc_enable_nat_gateway
    create_igw = true

    tags = var.vpc_tags
}

resource "aws_security_group" "http_sg" {
    name = "sg"
    vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.http_sg.id
    
    description = "Allow http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

}
resource "aws_security_group_rule" "allow_ssh_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.http_sg.id
    
    description = "Allow sshd"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

}
resource "aws_security_group_rule" "allow_outbound" {
    type = "egress"
    security_group_id = aws_security_group.http_sg.id
    
    description = "Allow outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

}
resource "aws_lb" "test" {
     name = "fib-test-elb"
     load_balancer_type = "application"
     subnets = module.vpc.public_subnets
     security_groups = [aws_security_group.http_sg.id]

}

resource "aws_lb_listener" "listener" {
     load_balancer_arn = aws_lb.test.arn
     port = "80"
     protocol = "HTTP"

     default_action {
       type = "forward"
       target_group_arn = aws_lb_target_group.tg.arn
     }
}

resource "aws_lb_target_group" "tg" {
    port = 80
    protocol = "HTTP"
    target_type = "instance"
    vpc_id = module.vpc.vpc_id

}

resource "aws_launch_configuration" "launch_config" {
    name = "lg"
    image_id = var.image_id
    instance_type =  "t2.micro"
    key_name = var.key_name
    security_groups = [aws_security_group.http_sg.id]
}

resource "aws_autoscaling_group" "asg" {
    name = "asg"
    launch_configuration = aws_launch_configuration.launch_config.name
    max_size = var.maxsize
    min_size = var.minsize
    target_group_arns = [ aws_lb_target_group.tg.arn]
    vpc_zone_identifier = [module.vpc.public_subnets[0],module.vpc.public_subnets[1]]
}