output "branch_network_id" {
  description = "Meraki network ID of the core branch network"
  value       = module.branch_network.network_id
}

output "guest_wifi_network_id" {
  description = "Meraki network ID of the guest WiFi network"
  value       = module.branch_guest_wifi.guest_network_id
}

output "monitoring_network_id" {
  description = "Meraki network ID of the monitoring network"
  value       = module.branch_monitoring.monitoring_network_id
}
