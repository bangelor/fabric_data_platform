# Domain Workspace Module - Simplified

# Look up the Platform Admins group (created in dev environment)
data "azuread_group" "platform_admins" {
  display_name     = "lbn_SG-Fabric-Platform-Admins"
  security_enabled = true
}

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
    id   = data.azuread_group.platform_admins.object_id
    type = "Group"
  }
  role = "Admin"
}
