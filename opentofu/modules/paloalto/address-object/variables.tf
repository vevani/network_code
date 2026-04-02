variable "vsys" {
  description = "Virtual system name (e.g. 'vsys1')"
  type        = string
  default     = "vsys1"
}

variable "address_objects" {
  description = "List of address objects to create"
  type = list(object({
    name        = string
    description = optional(string, "")
    type        = optional(string, "ip-netmask")
    value       = string
    tags        = optional(list(string), [])
  }))
  default = []
}

variable "address_groups" {
  description = "List of address groups to create"
  type = list(object({
    name           = string
    description    = optional(string, "")
    static_members = optional(list(string), [])
    tags           = optional(list(string), [])
  }))
  default = []
}
