variable "network_id" {
  description = "Target Meraki network ID"
  type        = string
}

variable "allowed_url_patterns" {
  description = "Glob patterns explicitly allowed"
  type        = list(string)
  default     = []
}

variable "blocked_url_patterns" {
  description = "Glob patterns blocked"
  type        = list(string)
  default     = []
}

variable "blocked_url_categories" {
  description = "List of Meraki content categories to block"
  type = list(object({
    id   = string
    name = string
  }))
  default = []
}

variable "url_category_list_size" {
  description = "Category list size: 'topSites' or 'fullList'"
  type        = string
  default     = "topSites"
}


