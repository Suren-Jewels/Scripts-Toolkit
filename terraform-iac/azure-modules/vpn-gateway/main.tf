resource "azurerm_public_ip" "vpn_public_ip" {
  name                = "${var.name}-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = var.tags
}

resource "azurerm_virtual_network_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = var.vpn_type
  active_active       = var.active_active
  enable_bgp          = var.enable_bgp
  sku                 = var.sku

  ip_configuration {
    name                          = "vpngw-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpn_public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  bgp_settings {
    asn = var.bgp_asn
    peering_addresses {
      ip_configuration_name = "vpngw-ipconfig"
    }
  }

  tags = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "connections" {
  count               = length(var.connections)
  name                = var.connections[count.index].name
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = var.connections[count.index].type
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id   = var.connections[count.index].local_gateway_id
  shared_key                 = var.connections[count.index].shared_key
}
