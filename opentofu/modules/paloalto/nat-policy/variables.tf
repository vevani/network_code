variable "vsys" {
  description = "Virtual system name (e.g. 'vsys1')"
  type        = string
  default     = "vsys1"
}

variable "nat_rules" {
  description = "List of NAT rules to configure"
  type = list(object({
    name                           = string
    description                    = optional(string, "")
    tags                           = optional(list(string), [])
    source_zones                   = list(string)
    destination_zone               = string
    destination_interface          = optional(string, "any")
    service                        = optional(string, "any")
    source_addresses               = optional(list(string), ["any"])
    destination_addresses          = optional(list(string), ["any"])
    translated_source_type         = optional(string, "dynamic-ip-and-port")
    translated_source_interface    = optional(string, "ethernet1/1")
    translated_destination_address = optional(string, "")
    translated_destination_port    = optional(number, null)
  }))
  default = []
}
