output "instance_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.web_server[*].public_ip
}

output "ssh_connection_strings" {
  description = "SSH connection strings for the EC2 instances"
  value       = [
    for instance in aws_instance.web_server :
    "ssh -i ${var.key_name}.pem ec2-user@${instance.public_ip}"
  ]
}

output "load_balancer_dns" {
  description = "DNS name of the Classic Load Balancer"
  value       = aws_elb.web_lb.dns_name
}