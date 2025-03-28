[master]
master-node ansible_host=${master_ip} ansible_user=ubuntu ansible_ssh_private_key_file=ubuntu-machine

[workers]
%{ for worker_ip in worker_ips ~}
worker-node-${count.index} ansible_host=${worker_ip} ansible_user=ubuntu 
%{ endfor ~}
