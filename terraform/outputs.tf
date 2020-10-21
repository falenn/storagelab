# Display some output
output "K8s-Main-Node-Public-IP" {
  value = aws_instance.k8s-master.public_ip
}

output "K8s-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.k8s-worker :
    instance.id => instance.public_ip
  }
}


