# Variables for Fabric Data Platform Infrastructure

variable "fabric_capacity_id" {
  description = "Fabric capacity UUID (GUID) from Fabric Portal: Settings > License Configuration > Capacity ID"
  type        = string
}

variable "business_domains" {
  description = "List of business domains for workspace and group creation (prod only)"
  type        = list(string)
  default     = [] # Empty by default for dev/test
}

variable "environment" {
  description = "Environment name (dev, test, or prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}
