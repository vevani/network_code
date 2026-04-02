data "meraki_organizations" "all" {}

locals {
  meraki_org_id = one([
    for org in data.meraki_organizations.all.items : org.id
    if lower(org.name) == lower(var.meraki_org_name)
  ])
}


