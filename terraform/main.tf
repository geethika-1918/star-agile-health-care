provider "aws" {
  region = "ap-south-1"
  profile = "default"
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
