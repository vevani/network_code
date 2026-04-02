output "wan1_enabled" {
  description = "Whether WAN 1 is enabled"
  value       = var.wan1_enabled
}

output "wan2_enabled" {
  description = "Whether WAN 2 (failover) is enabled"
  value       = var.wan2_enabled
}
