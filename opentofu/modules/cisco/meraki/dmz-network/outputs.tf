output "dmz_network_id" {
  description = "ID of the DMZ Meraki network"
  value       = meraki_networks.dmz.network_id
}

output "dmz_vlan_id" {
  description = "VLAN ID assigned to the DMZ"
  value       = meraki_networks_appliance_vlans.dmz.vlan_id
}
