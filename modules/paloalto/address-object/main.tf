resource "panos_address_object" "this" {
  for_each = { for obj in var.address_objects : obj.name => obj }

  vsys        = var.vsys
  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  value       = each.value.value
  tags        = each.value.tags
}

resource "panos_address_group" "this" {
  for_each = { for grp in var.address_groups : grp.name => grp }

  vsys             = var.vsys
  name             = each.value.name
  description      = each.value.description
  static_addresses = each.value.static_members
  tags             = each.value.tags

  depends_on = [panos_address_object.this]
}
