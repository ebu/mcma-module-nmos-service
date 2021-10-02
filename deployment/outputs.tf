output "vpn_client_private_key" {
  value = tls_private_key.vpn_client.private_key_pem
  sensitive = true
}

output "vpn_client_certificate" {
  value = tls_locally_signed_cert.vpn_client.cert_pem
  sensitive = true
}

output "vpn_endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.vpn.id
}

output "vpn_endpoint_name" {
  value = aws_ec2_client_vpn_endpoint.vpn.description
}
