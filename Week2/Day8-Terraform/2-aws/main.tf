# 1. Tạo VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true

  tags = { Name = "devops-training-vpc" }
}

# 2. Lấy danh sách Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# 3. Tạo 2 Public Subnet ở 2 AZ khác nhau
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-2" }
}

# 4. Tạo Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "devops-training-igw" }
}

# 5. Tạo Route Table và liên kết với Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-route-table" }
}

resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2_assoc" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# 6. Tạo Security Group (Cho phép SSH từ IP của bệ hạ và HTTP từ mọi nơi)
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "web-security-group" }
}

# 7. Lấy Image Amazon Linux 2023 mới nhất
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 8. Tạo EC2 t3.micro cài sẵn Nginx
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "hello from $(hostname -f)" > /usr/share/nginx/html/index.html
              EOF

  tags = { Name = "nginx-web-server" }
}

# 9. Gắn Elastic IP cho EC2
resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id
  domain   = "vpc"
  tags = { Name = "web-eip" }
}