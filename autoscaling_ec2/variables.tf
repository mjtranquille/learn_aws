variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}
variable "vpc_name" {
    type = string
    default = "testvpc"
}
variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type    = bool
  default = false
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default     = {
    Terraform   = "true"
    Environment = "dev"
  }
}
variable "image_id" {
  type = string
  default = "ami-1234567890"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
}

variable "maxsize" {
  description = "maximum size of auto scaling group"
  type = number
  default = 5
}
variable "minsize" {
  description = "minimum size of auto scaling group"
  type = number
  default = 2
}
