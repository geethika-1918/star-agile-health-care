terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

resource "aws_instance" "kubernetes_master" {
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t3.medium"
  key_name      = "ubuntu-machine"
  
  tags = {
    Name = "Kubernetes-Master"
  }
}

resource "aws_instance" "kubernetes_worker" {
  count         = 2
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t3.medium"
  key_name      = "ubuntu-machine"
  
  tags = {
    Name = "Kubernetes-Worker-${count.index}"
  }
}

output "master_ip" {
  value = aws_instance.kubernetes_master.public_ip
}

output "worker_ips" {
  value = aws_instance.kubernetes_worker[*].public_ip
}
