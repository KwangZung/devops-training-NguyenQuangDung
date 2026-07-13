variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR block"
}

variable "env" {
  type        = string
  description = "Environment name like dev, stg"
}