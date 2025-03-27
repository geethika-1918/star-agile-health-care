provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "kubernetes_master" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  key_name      = "your-key"
  
  tags = {
    Name = "Kubernetes-Master"
  }
}

resource "aws_instance" "kubernetes_worker" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  key_name      = "your-key"
  
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
