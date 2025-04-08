output "vpn_endpoint_id" {
  description = "ID VPN-эндпоинта"
  value       = aws_ec2_client_vpn_endpoint.vpn.id
}

output "vpn_dns_name" {
  description = "DNS-имя VPN-эндпоинта"
  value       = aws_ec2_client_vpn_endpoint.vpn.dns_name
}

output "vpn_security_group_id" {
  description = "ID группы безопасности для VPN"
  value       = aws_security_group.vpn_sg.id
}

output "client_cert_pem" {
  description = "Сертификат клиента в формате PEM"
  value       = tls_self_signed_cert.ca.cert_pem
  sensitive   = true
}

output "client_key_pem" {
  description = "Приватный ключ клиента в формате PEM"
  value       = tls_private_key.ca.private_key_pem
  sensitive   = true
}