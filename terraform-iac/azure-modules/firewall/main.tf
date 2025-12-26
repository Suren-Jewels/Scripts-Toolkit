resource "azurerm_public_ip" "firewall_public_ip" {
  name                = "${var.name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_firewall" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier

  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_public_ip.id
  }

  tags = var.tags
}

resource "azurerm_firewall_network_rule_collection" "network_rules" {
  count               = length(var.network_rules)
  name                = var.network_rules[count.index].name
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = var.resource_group_name
  priority            = var.network_rules[count.index].priority
  action              = var.network_rules[count.index].action

  rule {
    name                  = var.network_rules[count.index].rule_name
    source_addresses      = var.network_rules[count.index].source_addresses
    destination_addresses = var.network_rules[count.index].destination_addresses
    destination_ports     = var.network_rules[count.index].destination_ports
    protocols             = var.network_rules[count.index].protocols
  }
}

resource "azurerm_firewall_application_rule_collection" "app_rules" {
  count               = length(var.application_rules)
  name                = var.application_rules[count.index].name
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = var.resource_group_name
  priority            = var.application_rules[count.index].priority
  action              = var.application_rules[count.index].action

  rule {
    name             = var.application_rules[count.index].rule_name
    source_addresses = var.application_rules[count.index].source_addresses

    target_fqdns = var.application_rules[count.index].target_fqdns

    protocol {
      port = var.application_rules[count.index].protocol_port
      type = var.application_rules[count.index].protocol_type
    }
  }
}
