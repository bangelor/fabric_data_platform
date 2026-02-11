# Domain Workspace Module Variables

variable "workspace_name" {
  description = "Name of the domain workspace"
  type        = string
}

variable "capacity_id" {
  description = "Fabric capacity UUID"
  type        = string
}

variable "domain_id" {
  description = "Fabric domain ID to assign the workspace to"
  type        = string
}

variable "platform_admin_id" {
  description = "Object ID of the Platform Admin security group"
  type        = string
}

variable "core_workspace_id" {
  description = "ID of the core workspace for shortcut source"
  type        = string
}

variable "core_warehouse_id" {
  description = "ID of the core warehouse for shortcut source"
  type        = string
}

variable "core_warehouse_name" {
  description = "Name of the core warehouse for shortcut source"
  type        = string
}
