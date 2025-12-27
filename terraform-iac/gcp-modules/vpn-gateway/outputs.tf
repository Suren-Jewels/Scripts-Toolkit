output "vpn_gateway_name" {
  value = google_compute_vpn_gateway.this.name
}

output "vpn_gateway_self_link" {
  value = google_compute_vpn_gateway.this.self_link
}

output "vpn_tunnel_names" {
  value = google_compute_vpn_tunnel.tunnels[*].name
}
