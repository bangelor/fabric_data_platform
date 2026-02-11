# Core Workspace Module - Simplified

# Fabric Workspace for core data platform
resource "fabric_workspace" "core" {
  display_name = var.workspace_name
  description  = "Core Fabric workspace - ${title(var.environment)} environment"
  capacity_id  = var.capacity_id
}

# Assign Admin security group as Workspace Admin
resource "fabric_workspace_role_assignment" "admin" {
  workspace_id = fabric_workspace.core.id
  principal = {
    id   = var.admin_group_id
    type = "Group"
  }
  role = "Admin"
}

# Assign Contributor security group as Workspace Contributor
resource "fabric_workspace_role_assignment" "contributor" {
  workspace_id = fabric_workspace.core.id
  principal = {
    id   = var.contributor_group_id
    type = "Group"
  }
  role = "Contributor"
}

# Lakehouse for core workspace
resource "fabric_lakehouse" "core" {
  display_name = "core-lakehouse-${var.environment}"
  description  = "Core lakehouse for ${var.environment} environment"
  workspace_id = fabric_workspace.core.id
}

# Warehouse for core workspace
resource "fabric_warehouse" "core" {
  display_name = "core-warehouse-${var.environment}"
  description  = "Core warehouse for ${var.environment} environment"
  workspace_id = fabric_workspace.core.id
}
