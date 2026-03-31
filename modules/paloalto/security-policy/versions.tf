terraform {
  required_providers {
    panos = {
      source = "PaloAltoNetworks/panos"
      # Version is pinned in root modules/environments; keep modules flexible
    }
  }
}
