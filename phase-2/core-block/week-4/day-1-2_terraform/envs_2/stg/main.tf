terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name     = "name"
    values   = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name     = "virtualization-type"
    values   = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "stg_network" {
  source      = "../../modules/network"
  vpc_cidr    = "10.20.0.0/16"
  subnet_cidr = "10.20.1.0/24"
  env         = "stg"
}

module "stg_compute" {
  source        = "../../modules/compute"
  vpc_id        = module.stg_network.vpc_id
  subnet_id     = module.stg_network.subnet_id
  instance_type = "t3.micro" # Thay thế t3.medium bằng t3.micro để tương thích với chính sách Free Tier
  ami_id        = data.aws_ami.ubuntu.id
  env           = "stg"
}