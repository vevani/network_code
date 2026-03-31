output "network_id" {
  description = "Network ID applied"
  value       = var.network_id
}

output "vlan_ids" {
  description = "List of configured VLAN IDs"
  value       = [for v in meraki_networks_appliance_vlans.this : v.vlan_id]
}
