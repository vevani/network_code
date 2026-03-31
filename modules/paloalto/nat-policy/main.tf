resource "panos_nat_rule_group" "this" {
  vsys = var.vsys

  dynamic "rule" {
    for_each = var.nat_rules
    content {
      name        = rule.value.name
      description = rule.value.description
      tags        = rule.value.tags

      original_packet {
        source_zones          = rule.value.source_zones
        destination_zone      = rule.value.destination_zone
        destination_interface = rule.value.destination_interface
        service               = rule.value.service
        source_addresses      = rule.value.source_addresses
        destination_addresses = rule.value.destination_addresses
      }

      translated_packet {
        source {
          dynamic_ip_and_port {
            dynamic "interface_address" {
              for_each = rule.value.translated_source_type == "interface" ? [1] : []
              content {
                interface = rule.value.translated_source_interface
              }
            }
          }
        }

        destination {
          dynamic_translation {
            address = rule.value.translated_destination_address
            port    = rule.value.translated_destination_port
          }
        }
      }
    }
  }
}
