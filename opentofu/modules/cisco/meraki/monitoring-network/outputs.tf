output "monitoring_network_id" {
  description = "ID of the monitoring Meraki network"
  value       = meraki_networks.monitoring.network_id
}

output "mgmt_vlan_id" {
  description = "VLAN ID assigned to the management segment"
  value       = meraki_networks_appliance_vlans.mgmt.vlan_id
}
