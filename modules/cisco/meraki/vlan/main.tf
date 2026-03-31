resource "meraki_networks_appliance_vlans" "this" {
  for_each = { for vlan in var.vlans : tostring(vlan.vlan_id) => vlan }

  network_id    = var.network_id
  vlan_id       = each.value.vlan_id
  name          = each.value.name
  subnet        = each.value.subnet
  appliance_ip  = each.value.appliance_ip
  dhcp_handling = each.value.dhcp_handling
}
