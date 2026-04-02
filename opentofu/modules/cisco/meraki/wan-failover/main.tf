# WAN Failover Module
#
# Configures dual-WAN uplinks on a Meraki MX appliance for automatic
# failover and optional load balancing.
#
# Use case: Ensure business continuity by configuring a secondary ISP
# connection that activates automatically when the primary link fails.
# Optionally distribute traffic across both links for better performance.

resource "meraki_networks_appliance_uplinks_settings" "this" {
  network_id = var.network_id

  interfaces_wan1_enabled        = var.wan1_enabled
  interfaces_wan1_vlan_tagging_enabled = var.wan1_vlan != null
  interfaces_wan1_vlan_tagging_vlan_id = var.wan1_vlan

  interfaces_wan1_svis_ipv4_assignment_mode = var.wan1_using_static_ip ? "static" : "dynamic"
  interfaces_wan1_svis_ipv4_address         = var.wan1_static_ip
  interfaces_wan1_svis_ipv4_gateway         = var.wan1_static_gateway_ip

  interfaces_wan2_enabled        = var.wan2_enabled
  interfaces_wan2_vlan_tagging_enabled = var.wan2_vlan != null
  interfaces_wan2_vlan_tagging_vlan_id = var.wan2_vlan

  interfaces_wan2_svis_ipv4_assignment_mode = var.wan2_using_static_ip ? "static" : "dynamic"
  interfaces_wan2_svis_ipv4_address         = var.wan2_static_ip
  interfaces_wan2_svis_ipv4_gateway         = var.wan2_static_gateway_ip
}

resource "meraki_networks_appliance_traffic_shaping_rules" "this" {
  count      = length(var.traffic_shaping_rules) > 0 ? 1 : 0
  network_id = var.network_id

  dynamic "rules" {
    for_each = var.traffic_shaping_rules
    content {
      dscp_tag_value = rules.value.dscp_tag_value
      priority       = rules.value.priority

      per_client_bandwidth_limits_settings = rules.value.per_client_bandwidth_limits_settings

      dynamic "definitions" {
        for_each = rules.value.definitions
        content {
          type  = definitions.value.type
          value = definitions.value.value
        }
      }
    }
  }
}
