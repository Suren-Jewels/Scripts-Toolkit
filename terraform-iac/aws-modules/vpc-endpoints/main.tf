resource "aws_vpc_endpoint" "interface_endpoints" {
  count        = length(var.interface_endpoints)
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.${var.interface_endpoints[count.index]}"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  private_dns_enabled = var.private_dns_enabled

  tags = merge(
    var.tags,
    { Name = "${var.interface_endpoints[count.index]}-endpoint" }
  )
}

resource "aws_vpc_endpoint" "gateway_endpoints" {
  count        = length(var.gateway_endpoints)
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.${var.gateway_endpoints[count.index]}"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.route_table_ids

  tags = merge(
    var.tags,
    { Name = "${var.gateway_endpoints[count.index]}-endpoint" }
  )
}
