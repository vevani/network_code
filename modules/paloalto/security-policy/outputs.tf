output "vsys" {
  description = "Virtual system the rules were applied to"
  value       = var.vsys
}

output "rule_names" {
  description = "Names of the configured security rules"
  value       = [for r in var.rules : r.name]
}
