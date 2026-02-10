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

variable "git_provider_type" {
  description = "Git provider type (AzureDevOps or GitHub)"
  type        = string
  default     = "AzureDevOps"
  validation {
    condition     = contains(["AzureDevOps", "GitHub"], var.git_provider_type)
    error_message = "git_provider_type must be either 'AzureDevOps' or 'GitHub'."
  }
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
  validation {
    condition     = contains(["PreferWorkspace", "PreferGit"], var.git_initialization_strategy)
    error_message = "git_initialization_strategy must be either 'PreferWorkspace' or 'PreferGit'."
  }
}

variable "git_connection_id" {
  description = "Git connection ID - REQUIRED for GitHub. Create connection in Fabric Portal: Settings > Git integration > Connect"
  type        = string
  default     = ""
}

variable "dbt_enabled" {
  description = "Enable dbt integration"
  type        = bool
  default     = false
}

variable "capacity_id" {
  description = "ID of the existing Fabric capacity (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
