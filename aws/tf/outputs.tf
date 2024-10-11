output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.main.id
}

output "proxy_public_dns" {
  value = aws_instance.proxy.public_dns
}

output "proxy_public_ip" {
  value = aws_instance.proxy.public_ip
}
