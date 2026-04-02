variable "organization_id" {
  description = "Meraki organization ID"
  type        = string
}

variable "network_name" {
  description = "Name of the Meraki network"
  type        = string
}

variable "product_types" {
  description = "List of product types for the network"
  type        = list(string)
  default     = ["appliance", "switch", "wireless"]
}

variable "tags" {
  description = "Tags to apply to the network"
  type        = list(string)
  default     = []
}

variable "timezone" {
  description = "Timezone for the network"
  type        = string
  default     = "America/Los_Angeles"
}

variable "notes" {
  description = "Notes for the network"
  type        = string
  default     = ""
}

variable "enable_vlans" {
  description = "Enable VLANs for the network"
  type        = bool
  default     = true
}

variable "local_status_page_enabled" {
  description = "Enable local status page"
  type        = bool
  default     = false
}

variable "remote_status_page_enabled" {
  description = "Enable remote status page"
  type        = bool
  default     = true
}


