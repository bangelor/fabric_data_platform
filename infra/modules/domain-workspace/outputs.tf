# Domain Workspace Module Outputs

output "workspace_id" {
  description = "ID of the domain workspace"
  value       = fabric_workspace.domain.id
}

output "workspace_name" {
  description = "Name of the domain workspace"
  value       = fabric_workspace.domain.display_name
}
