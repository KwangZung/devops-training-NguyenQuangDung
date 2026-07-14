terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "dungnq-terraform-states"
    key          = "network/terraform.tfstate" # Lưu ở key network
    region       = "ap-southeast-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "this" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "shared-vpc"
  }
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.30.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "shared-subnet"
  }
}