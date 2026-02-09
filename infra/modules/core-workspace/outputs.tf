# Core Workspace Module Outputs

output "workspace_id" {
  description = "ID of the core Fabric workspace"
  value       = fabric_workspace.core.id
}

output "workspace_name" {
  description = "Name of the core Fabric workspace"
  value       = fabric_workspace.core.display_name
}

output "git_integration_enabled" {
  description = "Whether Git integration is enabled"
  value       = var.git_integration_enabled
}

output "dbt_enabled" {
  description = "Whether dbt is enabled"
  value       = var.dbt_enabled
}
