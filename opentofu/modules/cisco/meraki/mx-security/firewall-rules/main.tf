resource "meraki_networks_appliance_firewall_l3_firewall_rules" "this" {
  network_id = var.network_id

  dynamic "rules" {
    for_each = var.firewall_rules
    content {
      comment        = rules.value.comment
      dest_cidr      = rules.value.dest_cidr
      dest_port      = rules.value.dest_port
      policy         = rules.value.policy
      protocol       = rules.value.protocol
      src_cidr       = rules.value.src_cidr
      src_port       = rules.value.src_port
      syslog_enabled = rules.value.syslog_enabled
    }
  }
}

resource "meraki_networks_appliance_firewall_l7_firewall_rules" "this" {
  network_id = var.network_id

  dynamic "rules" {
    for_each = var.l7_firewall_rules
    content {
      policy = rules.value.policy
      type   = rules.value.type
      value  = rules.value.value
    }
  }
}


