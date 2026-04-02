variable "meraki_org_name" {
  description = "Meraki organization name"
  type        = string
}

variable "customer_slug" {
  description = "Short slug for the customer (kebab-case)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "branch_name" {
  description = "Short name for the branch office (e.g. branch-01, seattle)"
  type        = string
}

variable "timezone" {
  description = "Timezone for the branch network"
  type        = string
  default     = "America/New_York"
}

variable "hub_network_id" {
  description = "Network ID of the hub/HQ for AutoVPN"
  type        = string
}

variable "workstation_subnet" {
  description = "Subnet for the workstation VLAN"
  type        = string
  default     = "192.168.10.0/24"
}

variable "server_subnet" {
  description = "Subnet for the server VLAN"
  type        = string
  default     = "192.168.20.0/24"
}

variable "voip_subnet" {
  description = "Subnet for the VoIP VLAN"
  type        = string
  default     = "192.168.40.0/24"
}

variable "guest_subnet" {
  description = "Subnet for the guest WiFi VLAN"
  type        = string
  default     = "10.200.0.0/24"
}

variable "mgmt_subnet" {
  description = "Subnet for the management VLAN"
  type        = string
  default     = "10.255.0.0/24"
}

variable "snmp_community" {
  description = "SNMP community string for the monitoring network"
  type        = string
  default     = ""
  sensitive   = true
}
