output "vpcid" {
    value = module.vpc.vpc_id
}
output "subnet_id" {
    value = module.vpc.public_subnets
}
output "alb_dns_name" {
    value = aws_lb.test.dns_name
}