terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "kubernetes_master" {
  ami           = "ami-0e35ddab05955cf57" # Ensure the AMI ID is available in your region
  instance_type = "t3.medium"
  key_name      = "ubuntu-machine"
  
  tags = {
    Name = "Kubernetes-Master"
  }
}

resource "aws_instance" "kubernetes_worker" {
  count         = 2
  ami           = "ami-0e35ddab05955cf57" # Use an appropriate AMI for your region
  instance_type = "t3.medium"
  key_name      = "ubuntu-machine"
  
  tags = {
    Name = "Kubernetes-Worker-${count.index}"
  }
}

# Outputs for private IPs
output "master_private_ip" {
  description = "Private IP address of the Kubernetes Master instance"
  value       = aws_instance.kubernetes_master.private_ip
}

output "worker_private_ips" {
  description = "Private IP addresses of the Kubernetes Worker instances"
  value       = aws_instance.kubernetes_worker[*].private_ip
}

output "ansible_inventory" {
  value = templatefile("inventory.tpl", {
    master_ip  = aws_instance.kubernetes_master.private_ip,
    worker_ips = aws_instance.kubernetes_worker[*].private_ip,
    worker_count = 2 // Pass the count of worker instances
  })
}
}
