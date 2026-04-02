variable "organization_id" {
  description = "Meraki organization ID"
  type        = string
}

variable "network_name" {
  description = "Name of the guest WiFi network"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the guest network"
  type        = list(string)
  default     = []
}

variable "timezone" {
  description = "Timezone for the network"
  type        = string
  default     = "America/New_York"
}

variable "guest_vlan_id" {
  description = "VLAN ID for the guest network"
  type        = number
  default     = 200
}

variable "guest_vlan_name" {
  description = "Name of the guest VLAN"
  type        = string
  default     = "Guest-WiFi"
}

variable "guest_subnet" {
  description = "Subnet for the guest VLAN"
  type        = string
  default     = "10.200.0.0/24"
}

variable "guest_appliance_ip" {
  description = "Gateway IP for the guest VLAN"
  type        = string
  default     = "10.200.0.1"
}

variable "guest_dhcp_handling" {
  description = "DHCP handling mode for the guest VLAN"
  type        = string
  default     = "Run a DHCP server"
}

variable "bandwidth_limit_up" {
  description = "Per-client upstream bandwidth limit in Kbps (0 = unlimited)"
  type        = number
  default     = 5000
}

variable "bandwidth_limit_down" {
  description = "Per-client downstream bandwidth limit in Kbps (0 = unlimited)"
  type        = number
  default     = 10000
}

variable "blocked_url_patterns" {
  description = "URL patterns to block on the guest network"
  type        = list(string)
  default = [
    "*torrent*",
    "*proxy*",
  ]
}

variable "blocked_url_categories" {
  description = "URL categories to block on the guest network"
  type = list(object({
    id   = string
    name = string
  }))
  default = [
    {
      id   = "meraki:contentFiltering/category/1"
      name = "Adult and Pornography"
    },
    {
      id   = "meraki:contentFiltering/category/18"
      name = "Proxy Avoidance and Anonymizers"
    }
  ]
}

variable "url_category_list_size" {
  description = "Size of the URL category list (topSites or fullList)"
  type        = string
  default     = "topSites"
}

variable "guest_firewall_rules" {
  description = "L3 firewall rules for the guest network"
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
  default = [
    {
      comment        = "Allow DNS"
      dest_cidr      = "any"
      dest_port      = "53"
      policy         = "allow"
      protocol       = "udp"
      src_cidr       = "10.200.0.0/24"
      src_port       = "any"
      syslog_enabled = false
    },
    {
      comment        = "Allow HTTPS outbound"
      dest_cidr      = "any"
      dest_port      = "443"
      policy         = "allow"
      protocol       = "tcp"
      src_cidr       = "10.200.0.0/24"
      src_port       = "any"
      syslog_enabled = false
    },
    {
      comment        = "Allow HTTP outbound"
      dest_cidr      = "any"
      dest_port      = "80"
      policy         = "allow"
      protocol       = "tcp"
      src_cidr       = "10.200.0.0/24"
      src_port       = "any"
      syslog_enabled = false
    },
    {
      comment        = "Deny access to internal networks"
      dest_cidr      = "10.0.0.0/8"
      dest_port      = "any"
      policy         = "deny"
      protocol       = "any"
      src_cidr       = "10.200.0.0/24"
      src_port       = "any"
      syslog_enabled = true
    },
    {
      comment        = "Deny access to internal networks (172)"
      dest_cidr      = "172.16.0.0/12"
      dest_port      = "any"
      policy         = "deny"
      protocol       = "any"
      src_cidr       = "10.200.0.0/24"
      src_port       = "any"
      syslog_enabled = true
    },
    {
      comment        = "Deny access to internal networks (192)"
      dest_cidr      = "192.168.0.0/16"
      dest_port      = "any"
      policy         = "deny"
      protocol       = "any"
      src_cidr       = "10.200.0.0/24"
      src_port       = "any"
      syslog_enabled = true
    }
  ]
}
