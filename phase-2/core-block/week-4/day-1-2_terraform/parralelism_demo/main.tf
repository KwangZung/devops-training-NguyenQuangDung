terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "a" {
  provisioner "local-exec" {
    command = "echo [CREATE] A start && powershell -Command Start-Sleep -Seconds 5 && echo [CREATE] A done"
  }
}

resource "null_resource" "b" {
  provisioner "local-exec" {
    command = "echo [CREATE] B start && powershell -Command Start-Sleep -Seconds 5 && echo [CREATE] B done"
  }
}

resource "null_resource" "c" {
  provisioner "local-exec" {
    command = "echo [CREATE] C start && powershell -Command Start-Sleep -Seconds 5 && echo [CREATE] C done"
  }
}