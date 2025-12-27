output "firewall_rule_names" {
  value = google_compute_firewall.rules[*].name
}

output "firewall_rule_self_links" {
  value = google_compute_firewall.rules[*].self_link
}
