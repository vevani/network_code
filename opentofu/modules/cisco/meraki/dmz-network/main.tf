# DMZ Network Module
#
# Provisions a DMZ (demilitarized zone) network on Meraki with strict
# segmentation between the DMZ, internal networks, and the internet.
#
# Use case: Host public-facing services (web servers, mail relays, reverse
# proxies) in a segmented network that prevents lateral movement to
# internal corporate resources.

resource "meraki_networks" "dmz" {
  organization_id = var.organization_id
  name            = var.network_name
  product_types   = ["appliance", "switch"]
  tags            = var.tags
  timezone        = var.timezone
  notes           = "DMZ – public-facing services network"
}

resource "meraki_networks_vlans_settings" "dmz" {
  network_id    = meraki_networks.dmz.network_id
  vlans_enabled = true
}

resource "meraki_networks_appliance_vlans" "dmz" {
  depends_on = [meraki_networks_vlans_settings.dmz]

  network_id    = meraki_networks.dmz.network_id
  vlan_id       = var.dmz_vlan_id
  name          = var.dmz_vlan_name
  subnet        = var.dmz_subnet
  appliance_ip  = var.dmz_appliance_ip
  dhcp_handling = "Do not respond to DHCP requests"
}

locals {
  # Rules allowing inbound traffic to DMZ on specified ports
  inbound_rules = [
    for port in var.dmz_allowed_inbound_ports : {
      comment        = "Allow inbound port ${port} to DMZ"
      dest_cidr      = var.dmz_subnet
      dest_port      = port
      policy         = "allow"
      protocol       = "tcp"
      src_cidr       = "any"
      src_port       = "any"
      syslog_enabled = var.enable_syslog
    }
  ]

  # Rules blocking DMZ from reaching internal subnets
  isolation_rules = [
    for subnet in var.internal_subnets : {
      comment        = "Deny DMZ to internal ${subnet}"
      dest_cidr      = subnet
      dest_port      = "any"
      policy         = "deny"
      protocol       = "any"
      src_cidr       = var.dmz_subnet
      src_port       = "any"
      syslog_enabled = var.enable_syslog
    }
  ]

  all_rules = concat(local.inbound_rules, local.isolation_rules)
}

resource "meraki_networks_appliance_firewall_l3_firewall_rules" "dmz" {
  network_id = meraki_networks.dmz.network_id

  dynamic "rules" {
    for_each = local.all_rules
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
