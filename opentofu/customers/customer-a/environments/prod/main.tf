module "shared" {
  source          = "../../../customer-a/shared"
  meraki_org_name = var.meraki_org_name
}

locals {
  base_tags = [var.customer_slug, var.environment]
}

module "branch_office_network" {
  source = "../../../../modules/cisco/meraki/network"

  organization_id = module.shared.meraki_org_id
  network_name    = "${var.customer_slug}-branch-office-${var.environment}"
  product_types   = ["appliance", "switch", "wireless"]
  tags            = concat(local.base_tags, ["branch-office"])
  timezone        = "America/New_York"
  notes           = "${var.environment} branch office network"
  enable_vlans    = true
}

module "headquarters_network" {
  source = "../../../../modules/cisco/meraki/network"

  organization_id = module.shared.meraki_org_id
  network_name    = "${var.customer_slug}-hq-${var.environment}"
  product_types   = ["appliance", "switch", "wireless", "camera"]
  tags            = concat(local.base_tags, ["headquarters"])
  timezone        = "America/New_York"
  notes           = "${var.environment} headquarters network"
  enable_vlans    = true
}

module "branch_security_policies" {
  source = "../../../../modules/cisco/meraki/mx-security/firewall-rules"

  network_id = module.branch_office_network.network_id

  firewall_rules = [
    {
      comment        = "Allow HTTPS traffic"
      dest_cidr      = "any"
      dest_port      = "443"
      policy         = "allow"
      protocol       = "tcp"
      src_cidr       = "192.168.1.0/24"
      src_port       = "any"
      syslog_enabled = true
    },
    {
      comment        = "Deny RFC1918 to RFC1918 across WAN"
      dest_cidr      = "10.0.0.0/8"
      dest_port      = "any"
      policy         = "deny"
      protocol       = "any"
      src_cidr       = "192.168.0.0/16"
      src_port       = "any"
      syslog_enabled = true
    }
  ]

  l7_firewall_rules = [
    {
      policy = "deny"
      type   = "applicationCategory"
      value  = "Social networks"
    }
  ]
}

module "branch_content_filtering" {
  source = "../../../../modules/cisco/meraki/mx-security/content-filtering"

  network_id = module.branch_office_network.network_id

  allowed_url_patterns = [
    "*.company.com",
    "*.github.com",
    "*.stackoverflow.com",
  ]

  blocked_url_patterns = [
    "*gambling*",
    "*casino*",
  ]

  blocked_url_categories = [
    {
      id   = "meraki:contentFiltering/category/1"
      name = "Adult and Pornography"
    },
    {
      id   = "meraki:contentFiltering/category/7"
      name = "Gaming"
    }
  ]

  url_category_list_size = "topSites"
}

module "branch_autovpn" {
  source = "../../../../modules/cisco/meraki/autovpn"

  network_id = module.branch_office_network.network_id
  mode       = "spoke"
  hubs = [
    {
      hub_id            = module.headquarters_network.network_id
      use_default_route = false
    }
  ]
  subnets = [
    {
      local_subnet = "192.168.1.0/24"
      use_vpn      = true
    }
  ]
}


