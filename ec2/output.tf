output "vpcid" {
    value = module.vpc.vpc_id
}
output "subnet_id" {
    value = module.vpc.public_subnets
}
output "instance_ip" {
  value = module.ec2-instance.public_ip
}

output "instance_id" {
  value = module.ec2-instance.id
}