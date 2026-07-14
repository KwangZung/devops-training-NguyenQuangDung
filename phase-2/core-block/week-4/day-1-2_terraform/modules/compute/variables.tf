variable "vpc_id" {
  type        = string
  description = "VPC ID where the EC2 instance will belong"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the EC2 instance will be created"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID used for the EC2 instance"
}

variable "env" {
  type        = string
  description = "Environment name like dev, stg"
}