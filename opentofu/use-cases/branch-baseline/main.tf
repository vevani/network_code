# Branch Baseline – standardised branch office deployment
#
# This use-case configuration composes several modules to roll out a
# complete branch office with a single apply:
#
#   1. Core branch network with VLANs (workstation, server, VoIP)
#   2. MX security policies (L3/L7 firewall, content filtering)
#   3. AutoVPN spoke connection back to HQ hub
#   4. Guest WiFi with full isolation
#   5. Monitoring/management network with SNMP and syslog

# ---------------------------------------------------------------------------
# Shared data – look up the organization ID
# ---------------------------------------------------------------------------
data "meraki_organizations" "this" {
}

locals {
  base_tags   = [var.customer_slug, var.environment, var.branch_name]
  branch_slug = "${var.customer_slug}-${var.branch_name}-${var.environment}"
  org_id = [
    for org in data.meraki_organizations.this.items :
    org.id if lower(org.name) == lower(var.meraki_org_name)
  ][0]
}

# ---------------------------------------------------------------------------
# 1. Core branch network
# ---------------------------------------------------------------------------
module "branch_network" {
  source = "../../modules/cisco/meraki/network"

  organization_id = local.org_id
  network_name    = local.branch_slug
  product_types   = ["appliance", "switch", "wireless"]
  tags            = local.base_tags
  timezone        = var.timezone
  notes           = "${var.environment} branch office – ${var.branch_name}"
  enable_vlans    = true
}

module "branch_vlans" {
  source = "../../modules/cisco/meraki/vlan"

  network_id = module.branch_network.network_id

  vlans = [
    {
      vlan_id      = 10
      name         = "Workstations"
      subnet       = var.workstation_subnet
      appliance_ip = cidrhost(var.workstation_subnet, 1)
    },
    {
      vlan_id      = 20
      name         = "Servers"
      subnet       = var.server_subnet
      appliance_ip = cidrhost(var.server_subnet, 1)
    },
    {
      vlan_id      = 40
      name         = "VoIP"
      subnet       = var.voip_subnet
      appliance_ip = cidrhost(var.voip_subnet, 1)
    },
  ]
}

# ---------------------------------------------------------------------------
# 2. MX security policies
# ---------------------------------------------------------------------------
module "branch_firewall" {
  source = "../../modules/cisco/meraki/mx-security/firewall-rules"

  network_id = module.branch_network.network_id

  firewall_rules = [
    {
      comment        = "Allow HTTPS outbound"
      dest_cidr      = "any"
      dest_port      = "443"
      policy         = "allow"
      protocol       = "tcp"
      src_cidr       = var.workstation_subnet
      src_port       = "any"
      syslog_enabled = true
    },
    {
      comment        = "Allow DNS outbound"
      dest_cidr      = "any"
      dest_port      = "53"
      policy         = "allow"
      protocol       = "udp"
      src_cidr       = var.workstation_subnet
      src_port       = "any"
      syslog_enabled = false
    },
    {
      comment        = "Deny RFC1918 lateral movement"
      dest_cidr      = "10.0.0.0/8"
      dest_port      = "any"
      policy         = "deny"
      protocol       = "any"
      src_cidr       = "192.168.0.0/16"
      src_port       = "any"
      syslog_enabled = true
    },
    {
      comment        = "Deny Telnet"
      dest_cidr      = "any"
      dest_port      = "23"
      policy         = "deny"
      protocol       = "tcp"
      src_cidr       = "any"
      src_port       = "any"
      syslog_enabled = true
    },
  ]

  l7_firewall_rules = [
    {
      policy = "deny"
      type   = "applicationCategory"
      value  = "Peer-to-peer (P2P)"
    },
  ]
}

module "branch_content_filtering" {
  source = "../../modules/cisco/meraki/mx-security/content-filtering"

  network_id = module.branch_network.network_id

  allowed_url_patterns = [
    "*.company.com",
    "*.github.com",
  ]

  blocked_url_patterns = [
    "*gambling*",
    "*casino*",
    "*torrent*",
  ]

  blocked_url_categories = [
    {
      id   = "meraki:contentFiltering/category/1"
      name = "Adult and Pornography"
    },
    {
      id   = "meraki:contentFiltering/category/7"
      name = "Gaming"
    },
    {
      id   = "meraki:contentFiltering/category/18"
      name = "Proxy Avoidance and Anonymizers"
    },
  ]

  url_category_list_size = "topSites"
}

# ---------------------------------------------------------------------------
# 3. AutoVPN spoke → HQ hub
# ---------------------------------------------------------------------------
module "branch_autovpn" {
  source = "../../modules/cisco/meraki/autovpn"

  network_id = module.branch_network.network_id
  mode       = "spoke"

  hubs = [
    {
      hub_id            = var.hub_network_id
      use_default_route = false
    },
  ]

  subnets = [
    {
      local_subnet = var.workstation_subnet
      use_vpn      = true
    },
    {
      local_subnet = var.server_subnet
      use_vpn      = true
    },
    {
      local_subnet = var.voip_subnet
      use_vpn      = true
    },
  ]
}

# ---------------------------------------------------------------------------
# 4. Guest WiFi (isolated)
# ---------------------------------------------------------------------------
module "branch_guest_wifi" {
  source = "../../modules/cisco/meraki/guest-wifi"

  organization_id = local.org_id
  network_name    = "${local.branch_slug}-guest"
  tags            = concat(local.base_tags, ["guest"])

  guest_vlan_id      = 200
  guest_subnet       = var.guest_subnet
  guest_appliance_ip = cidrhost(var.guest_subnet, 1)
}

# ---------------------------------------------------------------------------
# 5. Monitoring / management network
# ---------------------------------------------------------------------------
module "branch_monitoring" {
  source = "../../modules/cisco/meraki/monitoring-network"

  organization_id = local.org_id
  network_name    = "${local.branch_slug}-mgmt"
  tags            = concat(local.base_tags, ["management"])

  mgmt_vlan_id      = 999
  mgmt_subnet       = var.mgmt_subnet
  mgmt_appliance_ip = cidrhost(var.mgmt_subnet, 1)

  snmp_enabled   = true
  snmp_community = var.snmp_community

  monitoring_allowed_subnets = [var.workstation_subnet]
}
