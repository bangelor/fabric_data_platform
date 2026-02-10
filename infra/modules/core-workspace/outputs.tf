# Core Workspace Module Outputs

output "workspace_id" {
  description = "ID of the core Fabric workspace"
  value       = fabric_workspace.core.id
}

output "workspace_name" {
  description = "Name of the core Fabric workspace"
  value       = fabric_workspace.core.display_name
}
