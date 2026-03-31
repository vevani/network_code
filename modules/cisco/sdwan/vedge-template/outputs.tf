output "template_id" {
  description = "ID of the created device template"
  value       = sdwan_feature_device_template.this.id
}

output "template_name" {
  description = "Name of the device template"
  value       = sdwan_feature_device_template.this.name
}
