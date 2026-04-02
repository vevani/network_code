variable "vsys" {
  description = "Virtual system name (e.g. 'vsys1')"
  type        = string
  default     = "vsys1"
}

variable "position_keyword" {
  description = "Position keyword for rule placement: 'before', 'after', 'top', 'bottom'"
  type        = string
  default     = "bottom"
  validation {
    condition     = contains(["before", "after", "top", "bottom", ""], var.position_keyword)
    error_message = "position_keyword must be 'before', 'after', 'top', 'bottom', or ''."
  }
}

variable "position_reference" {
  description = "Reference rule name when position_keyword is 'before' or 'after'"
  type        = string
  default     = ""
}

variable "rules" {
  description = "List of security policy rules"
  type = list(object({
    name                  = string
    description           = optional(string, "")
    tags                  = optional(list(string), [])
    source_zones          = list(string)
    source_addresses      = optional(list(string), ["any"])
    source_users          = optional(list(string), ["any"])
    destination_zones     = list(string)
    destination_addresses = optional(list(string), ["any"])
    applications          = optional(list(string), ["any"])
    services              = optional(list(string), ["application-default"])
    categories            = optional(list(string), ["any"])
    action                = string
    log_start             = optional(bool, false)
    log_end               = optional(bool, true)
    log_setting           = optional(string, "")
    profile_setting       = optional(string, "")
    disabled              = optional(bool, false)
  }))
  default = []
}
