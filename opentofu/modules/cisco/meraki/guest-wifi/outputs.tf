output "guest_network_id" {
  description = "ID of the guest WiFi Meraki network"
  value       = meraki_networks.guest.network_id
}

output "guest_vlan_id" {
  description = "VLAN ID assigned to the guest network"
  value       = meraki_networks_appliance_vlans.guest.vlan_id
}
