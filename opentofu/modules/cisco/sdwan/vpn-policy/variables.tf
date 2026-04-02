variable "policy_name" {
  description = "Name of the centralized policy"
  type        = string
}

variable "description" {
  description = "Description for the centralized policy"
  type        = string
  default     = ""
}

variable "vpn_lists" {
  description = "VPN lists referenced by topology definitions"
  type = list(object({
    name        = string
    description = optional(string, "")
    vpn_ids     = list(string)
  }))
  default = []
}

variable "hub_and_spoke_topologies" {
  description = "Hub-and-spoke topology definitions"
  type = list(object({
    name          = string
    vpn_list_name = string
    spokes = list(object({
      site_list_id = string
      hubs = list(object({
        site_list_id    = string
        preference      = optional(string, "")
        ipv4_restriction = optional(bool, false)
      }))
    }))
  }))
  default = []
}
