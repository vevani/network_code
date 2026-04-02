variable "network_id" {
  description = "Target Meraki network ID"
  type        = string
}

variable "serial" {
  description = "Serial number of the Meraki switch device"
  type        = string
}

variable "switch_ports" {
  description = "List of switch port configurations"
  type = list(object({
    port_id           = string
    name              = optional(string, "")
    type              = optional(string, "access")
    vlan              = optional(number, 1)
    voice_vlan        = optional(number, null)
    allowed_vlans     = optional(string, "all")
    poe_enabled       = optional(bool, true)
    isolation_enabled = optional(bool, false)
    rstp_enabled      = optional(bool, true)
    stp_guard         = optional(string, "disabled")
    link_negotiation  = optional(string, "Auto negotiate")
    tags              = optional(list(string), [])
  }))
  default = []
}

variable "port_schedule" {
  description = "Optional port schedule to create and reference"
  type = object({
    name = string
  })
  default = null
}
