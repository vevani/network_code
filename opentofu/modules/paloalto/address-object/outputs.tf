output "address_object_names" {
  description = "Names of the created address objects"
  value       = [for o in panos_address_object.this : o.name]
}

output "address_group_names" {
  description = "Names of the created address groups"
  value       = [for g in panos_address_group.this : g.name]
}
