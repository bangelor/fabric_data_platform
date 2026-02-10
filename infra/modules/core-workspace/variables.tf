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
