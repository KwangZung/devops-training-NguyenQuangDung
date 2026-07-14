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
    key          = "app/terraform.tfstate" # Lưu ở key app riêng biệt
    region       = "ap-southeast-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# 1. Khai báo Data Source để đọc file State của dự án Network từ S3
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "dungnq-terraform-states"
    key    = "network/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# 2. Phân giải Ubuntu AMI động
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

# 3. Tạo máy chủ EC2 sử dụng subnet_id đọc từ State của dự án Network
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  
  # Đọc thông số subnet_id thông qua đối tượng data source
  subnet_id     = data.terraform_remote_state.network.outputs.subnet_id

  tags = {
    Name = "app-server"
  }
}