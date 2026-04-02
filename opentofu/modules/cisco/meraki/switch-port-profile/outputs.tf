output "network_id" {
  description = "Network ID applied"
  value       = var.network_id
}

output "configured_port_ids" {
  description = "List of configured switch port IDs"
  value       = [for p in meraki_devices_switch_ports.this : p.port_id]
}
