terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# A — không phụ thuộc ai
resource "null_resource" "vpc" {
  provisioner "local-exec" {
    command = "echo [CREATE] vpc && powershell -Command Start-Sleep -Seconds 2"
  }
}

# B — implicit: phụ thuộc vpc
resource "null_resource" "subnet" {
  triggers = {
    parent = null_resource.vpc.id
  }

  provisioner "local-exec" {
    command = "echo [CREATE] subnet && powershell -Command Start-Sleep -Seconds 2"
  }
}

# C — không tham chiếu ai → không có implicit
resource "null_resource" "sg" {
  provisioner "local-exec" {
    command = "echo [CREATE] sg && powershell -Command Start-Sleep -Seconds 2"
  }
}

# D — implicit (subnet) + explicit (sg)
resource "null_resource" "instance" {
  depends_on = [null_resource.sg]

  triggers = {
    parent = null_resource.subnet.id
  }

  provisioner "local-exec" {
    command = "echo [CREATE] instance && powershell -Command Start-Sleep -Seconds 2"
  }
}