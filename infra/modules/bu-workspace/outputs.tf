# Business Unit Workspace Module Outputs

output "workspace_id" {
  description = "ID of the BU Fabric workspace"
  value       = fabric_workspace.bu.id
}

output "workspace_name" {
  description = "Name of the BU Fabric workspace"
  value       = fabric_workspace.bu.display_name
}

output "core_workspace_id" {
  description = "ID of the core workspace this BU consumes from"
  value       = var.core_workspace_id
}
