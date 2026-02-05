# Variables for Fabric Data Platform Infrastructure

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "core_workspace_name" {
  description = "Name of the core Fabric workspace"
  type        = string
}

variable "bu_workspaces" {
  description = "Map of business unit workspaces to create"
  type = map(object({
    name        = string
    description = string
  }))
  default = {}
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}
