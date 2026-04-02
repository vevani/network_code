module "shared" {
  source          = "../../../customer-a/shared"
  meraki_org_name = var.meraki_org_name
}

locals {
  base_tags = [var.customer_slug, var.environment]
}

module "networks" {
  for_each = var.networks
  source   = "../../../../modules/cisco/meraki/network"

  organization_id            = module.shared.meraki_org_id
  network_name               = coalesce(try(each.value.name, null), each.key)
  product_types              = try(each.value.product_types, ["appliance", "switch", "wireless"])
  tags                       = concat(local.base_tags, try(each.value.tags, []))
  timezone                   = try(each.value.timezone, "America/New_York")
  notes                      = try(each.value.notes, "")
  enable_vlans               = try(each.value.enable_vlans, true)
  local_status_page_enabled  = try(each.value.local_status_page_enabled, false)
  remote_status_page_enabled = try(each.value.remote_status_page_enabled, true)
}

module "networks_security" {
  for_each = { for k, v in var.networks : k => v if try(v.include_security, false) }
  source   = "../../../../modules/cisco/meraki/mx-security/firewall-rules"

  network_id        = module.networks[each.key].network_id
  firewall_rules    = try(each.value.firewall_rules, [])
  l7_firewall_rules = try(each.value.l7_firewall_rules, [])
}

module "networks_content_filtering" {
  for_each = { for k, v in var.networks : k => v if try(v.include_content_filtering, false) }
  source   = "../../../../modules/cisco/meraki/mx-security/content-filtering"

  network_id             = module.networks[each.key].network_id
  allowed_url_patterns   = try(each.value.allowed_url_patterns, [])
  blocked_url_patterns   = try(each.value.blocked_url_patterns, [])
  blocked_url_categories = try(each.value.blocked_url_categories, [])
  url_category_list_size = try(each.value.url_category_list_size, "topSites")
}

module "networks_autovpn" {
  for_each = { for k, v in var.networks : k => v if try(v.include_autovpn, false) }
  source   = "../../../../modules/cisco/meraki/autovpn"

  network_id = module.networks[each.key].network_id
  mode       = try(each.value.autovpn.mode, "spoke")
  hubs       = try(each.value.autovpn.hubs, [])
  subnets    = try(each.value.autovpn.subnets, [])
}


