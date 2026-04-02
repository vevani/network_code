variable "template_name" {
  description = "Name of the device template"
  type        = string
}

variable "description" {
  description = "Description for the device template"
  type        = string
  default     = ""
}

variable "device_type" {
  description = "Device type (e.g. 'vedge-C8000V', 'vedge-ISR-4331')"
  type        = string
}

variable "device_role" {
  description = "Device role: 'sdwan-edge' or 'service-node'"
  type        = string
  default     = "sdwan-edge"
  validation {
    condition     = contains(["sdwan-edge", "service-node"], var.device_role)
    error_message = "device_role must be 'sdwan-edge' or 'service-node'."
  }
}

variable "feature_templates" {
  description = "List of feature template references to attach to the device template"
  type = list(object({
    id      = string
    type    = string
    version = optional(string, "1")
  }))
  default = []
}
