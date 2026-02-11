# Domain Workspace Module

# Fabric Workspace for domain
resource "fabric_workspace" "domain" {
  display_name = var.workspace_name
  description  = "Domain workspace for data consumption"
  capacity_id  = var.capacity_id
}

# Assign Platform Admin security group as Workspace Admin
resource "fabric_workspace_role_assignment" "admin" {
  workspace_id = fabric_workspace.domain.id
  principal = {
    id   = var.platform_admin_id
    type = "Group"
  }
  role = "Admin"
}

# Lakehouse for domain workspace
resource "fabric_lakehouse" "domain" {
  display_name = "domain-lakehouse"
  description  = "Domain lakehouse for data consumption"
  workspace_id = fabric_workspace.domain.id
}

# Shortcut to core warehouse gold schema
resource "fabric_shortcut" "warehouse_gold" {
  workspace_id = fabric_workspace.domain.id
  item_id      = fabric_lakehouse.domain.id
  path         = "Tables"
  name         = "core_warehouse_gold"

  target = {
    onelake = {
      workspace_id = var.core_workspace_id
      item_id      = var.core_warehouse_id
      path         = "Tables/gold"
    }
  }
}
