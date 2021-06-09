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
    private_subnets = var.vpc_private_subnets
    public_subnets  = var.vpc_public_subnets

    enable_nat_gateway = var.vpc_enable_nat_gateway
    create_igw = true

    tags = var.vpc_tags
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.15.0"
  ami = var.image_id
  instance_type = var.instance_type
  name = "test-instance"
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.http_sg.id]
  key_name = var.key_name
  user_data = <<EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    echo -e '<html>
      <body>
        <p> Fibonacci Site coming soon. </p>
      </body>
    </html>' > /var/www/html/index.html
    /etc/init.d/httpd start
    chkconfig httpd on
  EOF
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