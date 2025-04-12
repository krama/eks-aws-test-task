output "vpn_endpoint_id" {
  description = "ID of VPN endpoint"
  value       = length(aws_ec2_client_vpn_endpoint.vpn) > 0 ? aws_ec2_client_vpn_endpoint.vpn[0].id : "not-created-in-localstack"
}

output "vpn_dns_name" {
  description = "DNS name of VPN endpoint"
  value       = length(aws_ec2_client_vpn_endpoint.vpn) > 0 ? aws_ec2_client_vpn_endpoint.vpn[0].dns_name : "not-created-in-localstack"
}

output "vpn_security_group_id" {
  description = "ID of security group for VPN"
  value       = aws_security_group.vpn_sg.id
}

output "client_cert_pem" {
  description = "Client certificate in PEM format"
  value       = tls_self_signed_cert.ca.cert_pem
  sensitive   = true
}

output "client_key_pem" {
  description = "Client private key in PEM format"
  value       = tls_private_key.ca.private_key_pem
  sensitive   = true
}