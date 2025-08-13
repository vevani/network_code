meraki_org_name = "Cognizant SDWAN LAB"
customer_slug   = "customer-a"
environment     = "prod"
networks = {
  INBLR-DC01 = {
    name              = "INBLR-DC01"
    include_security  = true
    include_autovpn   = true
  }
  INBLR-BR01 = {
    name              = "INBLR-BR01"
    include_security  = true
    include_autovpn   = true
  }
  INBLR-BR02 = {
    name              = "INBLR-BR02"
    include_security  = true
    include_autovpn   = true
  }
  vMX1 = {
    name              = "vMX1"
    enable_vlans = false
    include_security  = true
    include_autovpn   = true
  }
  vMX2 = {
    name              = "vMX2"
    enable_vlans = false
    include_security  = true
    include_autovpn   = true
  }
}
