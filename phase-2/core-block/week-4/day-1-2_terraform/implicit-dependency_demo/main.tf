terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Resource A: không phụ thuộc ai
resource "null_resource" "vpc" {
  provisioner "local-exec" {
    command = "echo [CREATE] vpc && powershell -Command Start-Sleep -Seconds 2"
  }
}

# Resource B: implicit dependency vào A vì tham chiếu A
resource "null_resource" "subnet" {
  triggers = {
    parent = null_resource.vpc.id
  }

  provisioner "local-exec" {
    command = "echo [CREATE] subnet && powershell -Command Start-Sleep -Seconds 2"
  }
}

# Resource C: implicit dependency vào B
resource "null_resource" "instance" {
  triggers = {
    parent = null_resource.subnet.id
  }

  provisioner "local-exec" {
    command = "echo [CREATE] instance && powershell -Command Start-Sleep -Seconds 2"
  }
}