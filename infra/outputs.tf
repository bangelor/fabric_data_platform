# Main Infrastructure Outputs

# Core workspace outputs
output "core_workspace_id" {
  description = "ID of the core workspace"
  value       = module.core_workspace.workspace_id
}

output "core_workspace_name" {
  description = "Name of the core workspace"
  value       = module.core_workspace.workspace_name
}

output "core_variable_library_id" {
  description = "ID of the core deployment variable library"
  value       = module.core_workspace.variable_library_id
}

# Domain workspace outputs
output "domain_workspace_ids" {
  description = "Map of domain workspace names to their IDs"
  value       = { for k, v in module.domain_workspace : k => v.workspace_id }
}

output "domain_workspace_names" {
  description = "Map of domain workspace names to their display names"
  value       = { for k, v in module.domain_workspace : k => v.workspace_name }
}
