# Business Unit Workspace Module Variables

variable "workspace_name" {
  description = "Name of the BU Fabric workspace"
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

variable "core_workspace_id" {
  description = "ID of the core workspace for data consumption"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
