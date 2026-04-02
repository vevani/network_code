variable "network_id" {
  description = "Target Meraki network ID"
  type        = string
}

variable "firewall_rules" {
  description = "Layer 3 firewall rules"
  type = list(object({
    comment        = string
    dest_cidr      = string
    dest_port      = string
    policy         = string
    protocol       = string
    src_cidr       = string
    src_port       = string
    syslog_enabled = bool
  }))
  default = []
}

variable "l7_firewall_rules" {
  description = "Layer 7 firewall rules"
  type = list(object({
    policy = string
    type   = string
    value  = string
  }))
  default = []
}


