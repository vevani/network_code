resource "sdwan_centralized_policy" "this" {
  name        = var.policy_name
  description = var.description
}

resource "sdwan_topology_vpn_list" "this" {
  for_each = { for vpn in var.vpn_lists : vpn.name => vpn }

  name        = each.value.name
  description = each.value.description

  dynamic "entries" {
    for_each = each.value.vpn_ids
    content {
      vpn_id = entries.value
    }
  }
}

resource "sdwan_topology_hub_and_spoke_topology" "this" {
  count = length(var.hub_and_spoke_topologies)

  name        = var.hub_and_spoke_topologies[count.index].name
  vpn_list_id = sdwan_topology_vpn_list.this[var.hub_and_spoke_topologies[count.index].vpn_list_name].id

  dynamic "spokes" {
    for_each = var.hub_and_spoke_topologies[count.index].spokes
    content {
      site_list_id = spokes.value.site_list_id

      dynamic "hubs" {
        for_each = spokes.value.hubs
        content {
          site_list_id     = hubs.value.site_list_id
          preference       = hubs.value.preference
          ipv4_restriction = hubs.value.ipv4_restriction
        }
      }
    }
  }
}
