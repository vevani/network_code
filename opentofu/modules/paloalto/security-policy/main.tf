resource "panos_security_rule_group" "this" {
  vsys             = var.vsys
  position_keyword = var.position_keyword
  position_reference = var.position_reference

  dynamic "rule" {
    for_each = var.rules
    content {
      name                  = rule.value.name
      description           = rule.value.description
      tags                  = rule.value.tags
      source_zones          = rule.value.source_zones
      source_addresses      = rule.value.source_addresses
      source_users          = rule.value.source_users
      destination_zones     = rule.value.destination_zones
      destination_addresses = rule.value.destination_addresses
      applications          = rule.value.applications
      services              = rule.value.services
      categories            = rule.value.categories
      action                = rule.value.action
      log_start             = rule.value.log_start
      log_end               = rule.value.log_end
      log_setting           = rule.value.log_setting
      profile_setting       = rule.value.profile_setting
      disabled              = rule.value.disabled
    }
  }
}
