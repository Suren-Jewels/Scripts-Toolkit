output "interface_endpoint_ids" {
  value = aws_vpc_endpoint.interface_endpoints[*].id
}

output "gateway_endpoint_ids" {
  value = aws_vpc_endpoint.gateway_endpoints[*].id
}
