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

variable "fabric_capacity_name" {
  description = "Display name of the existing Fabric capacity to assign workspaces to (optional)"
  type        = string
  default     = ""
}

# Git Integration Variables
variable "git_integration_enabled" {
  description = "Enable Git integration for core workspace"
  type        = bool
  default     = false
}

variable "git_provider_type" {
  description = "Git provider type (AzureDevOps or GitHub)"
  type        = string
  default     = "AzureDevOps"
}

variable "git_organization_name" {
  description = "Azure DevOps organization name"
  type        = string
  default     = ""
}

variable "git_project_name" {
  description = "Azure DevOps project name"
  type        = string
  default     = ""
}

variable "git_owner_name" {
  description = "GitHub owner/organization name"
  type        = string
  default     = ""
}

variable "git_repository_name" {
  description = "Git repository name"
  type        = string
  default     = ""
}

variable "git_branch_name" {
  description = "Git branch name"
  type        = string
  default     = "main"
}

variable "git_directory_name" {
  description = "Directory path in the repository"
  type        = string
  default     = "/"
}

variable "git_initialization_strategy" {
  description = "Git initialization strategy (PreferWorkspace or PreferGit)"
  type        = string
  default     = "PreferWorkspace"
}

variable "git_credentials_source" {
  description = "Git credentials source (Automatic or ConfiguredConnection)"
  type        = string
  default     = "Automatic"
}

variable "git_connection_id" {
  description = "Git connection ID (required when git_credentials_source is ConfiguredConnection)"
  type        = string
  default     = null
}
