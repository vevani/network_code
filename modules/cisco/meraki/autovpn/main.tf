resource "meraki_networks_appliance_vpn_site_to_site" "this" {
  network_id = var.network_id
  mode       = var.mode

  dynamic "hubs" {
    for_each = var.mode == "spoke" ? var.hubs : []
    content {
      hub_id            = hubs.value.hub_id
      use_default_route = hubs.value.use_default_route
    }
  }

  dynamic "subnets" {
    for_each = var.subnets
    content {
      local_subnet = subnets.value.local_subnet
      use_vpn      = subnets.value.use_vpn
    }
  }
}


