resource "meraki_networks_appliance_content_filtering" "this" {
  network_id = var.network_id

  allowed_url_patterns   = var.allowed_url_patterns
  blocked_url_patterns   = var.blocked_url_patterns
  blocked_url_categories = var.blocked_url_categories
  url_category_list_size = var.url_category_list_size
}


