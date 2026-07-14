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

module "dev_network" {
  source      = "../../modules/network"
  vpc_cidr    = "10.10.0.0/16"
  subnet_cidr = "10.10.1.0/24"
  env         = "dev"
}

module "dev_compute" {
  source        = "../../modules/compute"
  vpc_id        = module.dev_network.vpc_id
  subnet_id     = module.dev_network.subnet_id
  instance_type = "t3.micro"
  ami_id        = data.aws_ami.ubuntu.id
  env           = "dev"
}