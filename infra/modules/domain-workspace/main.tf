# Domain Workspace Module - Simplified

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
    id   = var.platform_admin_group_id
    type = "Group"
  }
  role = "Admin"
}
