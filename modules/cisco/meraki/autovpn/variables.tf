variable "network_id" {
  description = "Target Meraki network ID"
  type        = string
}

variable "mode" {
  description = "VPN mode: 'spoke' or 'hub'"
  type        = string
  validation {
    condition     = contains(["spoke", "hub"], var.mode)
    error_message = "mode must be 'spoke' or 'hub'."
  }
}

variable "hubs" {
  description = "Hub definitions when mode is 'spoke'"
  type = list(object({
    hub_id            = string
    use_default_route = bool
  }))
  default = []
}

variable "subnets" {
  description = "Local subnets and whether they participate in VPN"
  type = list(object({
    local_subnet = string
    use_vpn      = bool
  }))
  default = []
}


