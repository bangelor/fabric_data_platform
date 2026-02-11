# Domain Workspace Module Outputs

output "workspace_id" {
  description = "ID of the domain workspace"
  value       = fabric_workspace.domain.id
}

output "workspace_name" {
  description = "Name of the domain workspace"
  value       = fabric_workspace.domain.display_name
}

output "lakehouse_id" {
  description = "ID of the domain lakehouse"
  value       = fabric_lakehouse.domain.id
}

output "lakehouse_name" {
  description = "Name of the domain lakehouse"
  value       = fabric_lakehouse.domain.display_name
}

output "warehouse_gold_shortcut_id" {
  description = "ID of the shortcut to core warehouse gold schema"
  value       = fabric_shortcut.warehouse_gold.id
}

output "warehouse_gold_shortcut_path" {
  description = "Path of the shortcut to core warehouse gold schema"
  value       = fabric_shortcut.warehouse_gold.path
}
