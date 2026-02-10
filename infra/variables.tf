# Variables for Fabric Data Platform Infrastructure

variable "fabric_capacity_id" {
  description = "Fabric capacity UUID (GUID) from Fabric Portal: Settings > License Configuration > Capacity ID"
  type        = string
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

variable "git_connection_id" {
  description = "Git connection ID - REQUIRED for GitHub. Create in Fabric Portal under workspace Settings > Git integration"
  type        = string
  default     = ""
}
