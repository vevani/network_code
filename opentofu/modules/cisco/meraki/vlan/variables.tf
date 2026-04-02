variable "network_id" {
  description = "Target Meraki network ID"
  type        = string
}

variable "vlans" {
  description = "List of VLANs to configure on the MX appliance"
  type = list(object({
    vlan_id       = number
    name          = string
    subnet        = string
    appliance_ip  = string
    dhcp_handling = optional(string, "Run a DHCP server")
  }))
  default = []
}
