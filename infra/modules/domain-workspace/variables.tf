# Domain Workspace Module Variables

variable "workspace_name" {
  description = "Name of the domain workspace"
  type        = string
}

variable "capacity_id" {
  description = "Fabric capacity UUID"
  type        = string
}

variable "platform_admin_group_id" {
  description = "Object ID of the Platform Admin security group"
  type        = string
}
