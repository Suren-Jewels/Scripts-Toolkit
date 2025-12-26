resource "aws_customer_gateway" "this" {
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = var.tags
}

resource "aws_vpn_gateway" "this" {
  vpc_id = var.vpc_id

  tags = var.tags
}

resource "aws_vpn_gateway_attachment" "attach" {
  vpc_id         = var.vpc_id
  vpn_gateway_id = aws_vpn_gateway.this.id
}

resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = aws_customer_gateway.this.id
  type                = "ipsec.1"

  static_routes_only = var.static_routes_only

  tags = var.tags
}

resource "aws_vpn_connection_route" "routes" {
  count                  = length(var.route_destinations)
  vpn_connection_id      = aws_vpn_connection.this.id
  destination_cidr_block = var.route_destinations[count.index]
}
