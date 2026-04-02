variable "network_id" {
  description = "Target Meraki network ID"
  type        = string
}

variable "wan1_enabled" {
  description = "Enable WAN 1 uplink"
  type        = bool
  default     = true
}

variable "wan1_vlan" {
  description = "VLAN tag for WAN 1 (null for untagged)"
  type        = number
  default     = null
}

variable "wan1_static_ip" {
  description = "Static IP for WAN 1 (null for DHCP)"
  type        = string
  default     = null
}

variable "wan1_static_gateway_ip" {
  description = "Gateway IP for WAN 1 static configuration"
  type        = string
  default     = null
}

variable "wan1_static_subnet_mask" {
  description = "Subnet mask for WAN 1 static configuration"
  type        = string
  default     = null
}

variable "wan1_static_dns" {
  description = "DNS servers for WAN 1 static configuration"
  type        = list(string)
  default     = []
}

variable "wan1_using_static_ip" {
  description = "Whether WAN 1 uses static IP (false = DHCP)"
  type        = bool
  default     = false
}

variable "wan2_enabled" {
  description = "Enable WAN 2 uplink for failover"
  type        = bool
  default     = true
}

variable "wan2_vlan" {
  description = "VLAN tag for WAN 2 (null for untagged)"
  type        = number
  default     = null
}

variable "wan2_static_ip" {
  description = "Static IP for WAN 2 (null for DHCP)"
  type        = string
  default     = null
}

variable "wan2_static_gateway_ip" {
  description = "Gateway IP for WAN 2 static configuration"
  type        = string
  default     = null
}

variable "wan2_static_subnet_mask" {
  description = "Subnet mask for WAN 2 static configuration"
  type        = string
  default     = null
}

variable "wan2_static_dns" {
  description = "DNS servers for WAN 2 static configuration"
  type        = list(string)
  default     = []
}

variable "wan2_using_static_ip" {
  description = "Whether WAN 2 uses static IP (false = DHCP)"
  type        = bool
  default     = false
}

variable "load_balancing_enabled" {
  description = "Enable load balancing across WAN uplinks"
  type        = bool
  default     = false
}

variable "failover_and_failback_immediate_enabled" {
  description = "Enable immediate failover and failback"
  type        = bool
  default     = true
}

variable "traffic_shaping_rules" {
  description = "Traffic shaping rules for WAN uplinks"
  type = list(object({
    dscp_tag_value                       = optional(number)
    priority                             = optional(string, "normal")
    per_client_bandwidth_limits_settings = optional(string, "network default")
    definitions = list(object({
      type  = string
      value = string
    }))
  }))
  default = []
}
