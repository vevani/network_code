output "policy_id" {
  description = "ID of the centralized policy"
  value       = sdwan_centralized_policy.this.id
}

output "vpn_list_ids" {
  description = "Map of VPN list names to their IDs"
  value       = { for k, v in sdwan_topology_vpn_list.this : k => v.id }
}
