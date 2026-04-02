meraki_org_name = "Customer A"
customer_slug   = "customer-a"
environment     = "prod"
networks = {
  dc01 = {
    name             = "customer-a-dc01-prod"
    include_security = true
    include_autovpn  = true
  }
  branch01 = {
    name             = "customer-a-branch01-prod"
    include_security = true
    include_autovpn  = true
  }
  branch02 = {
    name             = "customer-a-branch02-prod"
    include_security = true
    include_autovpn  = true
  }
  vmx1 = {
    name             = "customer-a-vmx1-prod"
    enable_vlans     = false
    include_security = true
    include_autovpn  = true
  }
  vmx2 = {
    name             = "customer-a-vmx2-prod"
    enable_vlans     = false
    include_security = true
    include_autovpn  = true
  }
}
