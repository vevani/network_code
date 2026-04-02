resource "sdwan_feature_device_template" "this" {
  name        = var.template_name
  description = var.description
  device_type = var.device_type
  device_role = var.device_role

  dynamic "general_templates" {
    for_each = var.feature_templates
    content {
      id      = general_templates.value.id
      type    = general_templates.value.type
      version = general_templates.value.version
    }
  }
}
