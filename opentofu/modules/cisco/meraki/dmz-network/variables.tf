variable "organization_id" {
  description = "Meraki organization ID"
  type        = string
}

variable "network_name" {
  description = "Name of the DMZ network"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the DMZ network"
  type        = list(string)
  default     = []
}

variable "timezone" {
  description = "Timezone for the network"
  type        = string
  default     = "America/New_York"
}

variable "dmz_vlan_id" {
  description = "VLAN ID for the DMZ segment"
  type        = number
  default     = 50
}

variable "dmz_vlan_name" {
  description = "Name of the DMZ VLAN"
  type        = string
  default     = "DMZ"
}

variable "dmz_subnet" {
  description = "Subnet for the DMZ VLAN"
  type        = string
  default     = "172.16.50.0/24"
}

variable "dmz_appliance_ip" {
  description = "Gateway IP for the DMZ VLAN"
  type        = string
  default     = "172.16.50.1"
}

variable "internal_subnets" {
  description = "List of internal subnets that DMZ should be isolated from"
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "192.168.0.0/16",
  ]
}

variable "dmz_allowed_inbound_ports" {
  description = "List of ports to allow inbound to the DMZ from the internet"
  type        = list(string)
  default     = ["443", "80"]
}

variable "enable_syslog" {
  description = "Enable syslog for firewall rules"
  type        = bool
  default     = true
}
