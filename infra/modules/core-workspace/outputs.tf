# Core Workspace Module Outputs

output "workspace_id" {
  description = "ID of the core Fabric workspace"
  value       = fabric_workspace.core.id
}

output "workspace_name" {
  description = "Name of the core Fabric workspace"
  value       = fabric_workspace.core.display_name
}

output "lakehouse_id" {
  description = "ID of the core lakehouse"
  value       = fabric_lakehouse.core.id
}

output "lakehouse_name" {
  description = "Name of the core lakehouse"
  value       = fabric_lakehouse.core.display_name
}

output "warehouse_id" {
  description = "ID of the core warehouse"
  value       = fabric_warehouse.core.id
}

output "warehouse_name" {
  description = "Name of the core warehouse"
  value       = fabric_warehouse.core.display_name
}
