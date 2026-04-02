resource "meraki_networks" "this" {
  organization_id = var.organization_id
  name            = var.network_name
  product_types   = var.product_types
  tags            = var.tags
  timezone        = var.timezone
  notes           = var.notes
}

resource "meraki_networks_vlans_settings" "this" {
  count         = var.enable_vlans ? 1 : 0
  network_id    = meraki_networks.this.network_id
  vlans_enabled = var.enable_vlans
}

resource "meraki_networks_settings" "this" {
  network_id = meraki_networks.this.network_id
  local_status_page_enabled  = var.local_status_page_enabled
  remote_status_page_enabled = var.remote_status_page_enabled
}


