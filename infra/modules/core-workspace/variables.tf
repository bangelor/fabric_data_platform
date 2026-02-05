# Core Workspace Module Variables

variable "workspace_name" {
  description = "Name of the Fabric workspace"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "create_resource_group" {
  description = "Whether to create the resource group"
  type        = bool
  default     = false
}

variable "git_integration_enabled" {
  description = "Enable Git integration for workspace"
  type        = bool
  default     = false
}

variable "git_repo_url" {
  description = "Git repository URL for sync"
  type        = string
  default     = ""
}

variable "dbt_enabled" {
  description = "Enable dbt integration"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
