variable "organization_id" {
  description = "Meraki organization ID"
  type        = string
}

variable "network_name" {
  description = "Name of the monitoring/management network"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the monitoring network"
  type        = list(string)
  default     = []
}

variable "timezone" {
  description = "Timezone for the network"
  type        = string
  default     = "America/New_York"
}

variable "mgmt_vlan_id" {
  description = "VLAN ID for the management/monitoring segment"
  type        = number
  default     = 999
}

variable "mgmt_vlan_name" {
  description = "Name of the management VLAN"
  type        = string
  default     = "Management"
}

variable "mgmt_subnet" {
  description = "Subnet for the management VLAN"
  type        = string
  default     = "10.255.0.0/24"
}

variable "mgmt_appliance_ip" {
  description = "Gateway IP for the management VLAN"
  type        = string
  default     = "10.255.0.1"
}

variable "snmp_community" {
  description = "SNMP community string for monitoring access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "snmp_enabled" {
  description = "Enable SNMP on the network"
  type        = bool
  default     = true
}

variable "snmp_access" {
  description = "SNMP access type: community or users"
  type        = string
  default     = "community"
}

variable "syslog_servers" {
  description = "Syslog servers for centralized logging"
  type = list(object({
    host  = string
    port  = number
    roles = list(string)
  }))
  default = []
}

variable "monitoring_allowed_subnets" {
  description = "Subnets allowed to reach the management network (e.g. NOC, jump hosts)"
  type        = list(string)
  default     = []
}

variable "enable_remote_status_page" {
  description = "Enable the Meraki remote status page for monitoring"
  type        = bool
  default     = true
}
