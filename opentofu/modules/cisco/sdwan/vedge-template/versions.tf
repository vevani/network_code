terraform {
  required_providers {
    sdwan = {
      source = "CiscoDevNet/sdwan"
      # Version is pinned in root modules/environments; keep modules flexible
    }
  }
}
