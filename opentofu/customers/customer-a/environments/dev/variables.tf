variable "meraki_org_name" {
  description = "Meraki organization name to deploy into"
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

variable "networks" {
  description = "Map of networks to manage and optionally secure. Keys are identifiers; values can set name, product_types, tags, security, vpn, etc."
  type = map(object({
    name                     = optional(string)
    product_types            = optional(list(string))
    tags                     = optional(list(string))
    timezone                 = optional(string)
    notes                    = optional(string)
    enable_vlans             = optional(bool)
    include_security         = optional(bool)
    firewall_rules           = optional(list(object({
      comment        = string
      dest_cidr      = string
      dest_port      = string
      policy         = string
      protocol       = string
      src_cidr       = string
      src_port       = string
      syslog_enabled = bool
    })))
    l7_firewall_rules        = optional(list(object({
      policy = string
      type   = string
      value  = string
    })))
    include_content_filtering = optional(bool)
    allowed_url_patterns      = optional(list(string))
    blocked_url_patterns      = optional(list(string))
    blocked_url_categories    = optional(list(object({ id = string, name = string })))
    url_category_list_size    = optional(string)
    include_autovpn           = optional(bool)
    autovpn = optional(object({
      mode    = optional(string)
      hubs    = optional(list(object({ hub_id = string, use_default_route = bool })))
      subnets = optional(list(object({ local_subnet = string, use_vpn = bool })))
    }))
  }))
  default = {}
}


