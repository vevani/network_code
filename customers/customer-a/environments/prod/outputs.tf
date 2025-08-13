output "branch_office_network_id" {
  description = "Branch office Meraki network ID"
  value       = module.branch_office_network.network_id
}

output "headquarters_network_id" {
  description = "Headquarters Meraki network ID"
  value       = module.headquarters_network.network_id
}


