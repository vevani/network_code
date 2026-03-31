output "vsys" {
  description = "Virtual system the NAT rules were applied to"
  value       = var.vsys
}

output "rule_names" {
  description = "Names of the configured NAT rules"
  value       = [for r in var.nat_rules : r.name]
}
