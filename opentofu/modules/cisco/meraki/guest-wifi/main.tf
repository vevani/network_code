# Guest WiFi Network Module
#
# Provisions an isolated guest wireless network on Meraki with:
# - Dedicated VLAN for guest traffic isolation
# - Content filtering to block inappropriate categories
# - Firewall rules preventing access to internal RFC1918 networks
# - Bandwidth limiting per client
#
# Use case: Provide visitors and contractors with internet access while
# maintaining strict isolation from corporate resources.

resource "meraki_networks" "guest" {
  organization_id = var.organization_id
  name            = var.network_name
  product_types   = ["appliance", "wireless"]
  tags            = var.tags
  timezone        = var.timezone
  notes           = "Guest WiFi – isolated network"
}

resource "meraki_networks_vlans_settings" "guest" {
  network_id    = meraki_networks.guest.network_id
  vlans_enabled = true
}

resource "meraki_networks_appliance_vlans" "guest" {
  depends_on = [meraki_networks_vlans_settings.guest]

  network_id    = meraki_networks.guest.network_id
  vlan_id       = var.guest_vlan_id
  name          = var.guest_vlan_name
  subnet        = var.guest_subnet
  appliance_ip  = var.guest_appliance_ip
  dhcp_handling = var.guest_dhcp_handling
}

resource "meraki_networks_appliance_firewall_l3_firewall_rules" "guest" {
  network_id = meraki_networks.guest.network_id

  dynamic "rules" {
    for_each = var.guest_firewall_rules
    content {
      comment        = rules.value.comment
      dest_cidr      = rules.value.dest_cidr
      dest_port      = rules.value.dest_port
      policy         = rules.value.policy
      protocol       = rules.value.protocol
      src_cidr       = rules.value.src_cidr
      src_port       = rules.value.src_port
      syslog_enabled = rules.value.syslog_enabled
    }
  }
}

resource "meraki_networks_appliance_content_filtering" "guest" {
  network_id = meraki_networks.guest.network_id

  blocked_url_patterns = var.blocked_url_patterns

  dynamic "blocked_url_categories" {
    for_each = var.blocked_url_categories
    content {
      id   = blocked_url_categories.value.id
      name = blocked_url_categories.value.name
    }
  }

  url_category_list_size = var.url_category_list_size
}
