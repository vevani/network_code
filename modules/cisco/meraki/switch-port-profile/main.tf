resource "meraki_networks_switch_port_schedules" "this" {
  count      = var.port_schedule != null ? 1 : 0
  network_id = var.network_id
  name       = var.port_schedule.name
}

resource "meraki_devices_switch_ports" "this" {
  for_each = { for p in var.switch_ports : tostring(p.port_id) => p }

  serial  = var.serial
  port_id = each.value.port_id

  name              = each.value.name
  type              = each.value.type
  vlan              = each.value.vlan
  voice_vlan        = each.value.voice_vlan
  allowed_vlans     = each.value.allowed_vlans
  poe_enabled       = each.value.poe_enabled
  isolation_enabled = each.value.isolation_enabled
  rstp_enabled      = each.value.rstp_enabled
  stp_guard         = each.value.stp_guard
  link_negotiation  = each.value.link_negotiation
  tags              = each.value.tags
}
