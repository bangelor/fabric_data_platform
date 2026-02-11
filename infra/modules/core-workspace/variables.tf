# Core Workspace Module Variables

variable "workspace_name" {
  description = "Name of the Fabric workspace"
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
}

variable "capacity_id" {
  description = "Fabric capacity UUID"
  type        = string
}

variable "admin_group_id" {
  description = "Object ID of the Admin security group"
  type        = string
}

variable "contributor_group_id" {
  description = "Object ID of the Contributor security group"
  type        = string
}

variable "domain_admin_group_id" {
  description = "Object ID of domain/platform admin group for warehouse read access (prod only)"
  type        = string
  default     = ""
}
