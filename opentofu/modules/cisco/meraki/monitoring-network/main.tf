# Monitoring / Management Network Module
#
# Provisions a dedicated management and monitoring network on Meraki with:
# - Isolated management VLAN for out-of-band access
# - SNMP configuration for network monitoring tools
# - Syslog server forwarding for centralized logging
# - Strict firewall rules limiting management access to approved subnets
#
# Use case: Provide a secure, dedicated management plane for network
# monitoring tools (e.g. Zabbix, PRTG, LibreNMS) and jump hosts.

resource "meraki_networks" "monitoring" {
  organization_id = var.organization_id
  name            = var.network_name
  product_types   = ["appliance", "switch"]
  tags            = var.tags
  timezone        = var.timezone
  notes           = "Management and monitoring network"
}

resource "meraki_networks_settings" "monitoring" {
  network_id                 = meraki_networks.monitoring.network_id
  local_status_page_enabled  = true
  remote_status_page_enabled = var.enable_remote_status_page
}

resource "meraki_networks_vlans_settings" "monitoring" {
  network_id    = meraki_networks.monitoring.network_id
  vlans_enabled = true
}

resource "meraki_networks_appliance_vlans" "mgmt" {
  depends_on = [meraki_networks_vlans_settings.monitoring]

  network_id    = meraki_networks.monitoring.network_id
  vlan_id       = var.mgmt_vlan_id
  name          = var.mgmt_vlan_name
  subnet        = var.mgmt_subnet
  appliance_ip  = var.mgmt_appliance_ip
  dhcp_handling = "Do not respond to DHCP requests"
}

resource "meraki_networks_snmp" "monitoring" {
  count = var.snmp_enabled ? 1 : 0

  network_id       = meraki_networks.monitoring.network_id
  access           = var.snmp_access
  community_string = var.snmp_access == "community" ? var.snmp_community : null
}

resource "meraki_networks_syslog_servers" "monitoring" {
  count = length(var.syslog_servers) > 0 ? 1 : 0

  network_id = meraki_networks.monitoring.network_id

  dynamic "servers" {
    for_each = var.syslog_servers
    content {
      host  = servers.value.host
      port  = servers.value.port
      roles = servers.value.roles
    }
  }
}

locals {
  # Allow monitoring subnets to reach management VLAN
  allow_rules = [
    for subnet in var.monitoring_allowed_subnets : {
      comment        = "Allow monitoring from ${subnet}"
      dest_cidr      = var.mgmt_subnet
      dest_port      = "any"
      policy         = "allow"
      protocol       = "any"
      src_cidr       = subnet
      src_port       = "any"
      syslog_enabled = true
    }
  ]

  # Deny all other access to management VLAN
  deny_rules = [
    {
      comment        = "Deny all other access to management VLAN"
      dest_cidr      = var.mgmt_subnet
      dest_port      = "any"
      policy         = "deny"
      protocol       = "any"
      src_cidr       = "any"
      src_port       = "any"
      syslog_enabled = true
    }
  ]

  all_rules = concat(local.allow_rules, local.deny_rules)
}

resource "meraki_networks_appliance_firewall_l3_firewall_rules" "monitoring" {
  network_id = meraki_networks.monitoring.network_id

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
