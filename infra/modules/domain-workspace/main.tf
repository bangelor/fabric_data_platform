# ==============================================================================
# Domain Workspace Module - Acc Fabric Data Platform
# ==============================================================================

locals {
  name_prefix  = "acc_fabric"
  domain_label = title(var.domain_name)
}

# ------------------------------------------------------------------------------
# Workspace
# ------------------------------------------------------------------------------
resource "fabric_workspace" "domain" {
  display_name = "${local.name_prefix}_ws_${var.domain_name}_prod"
  description  = "${local.domain_label} domain workspace – data consumption and reporting"
  capacity_id  = var.capacity_id
}

# ------------------------------------------------------------------------------
# Role Assignments
# ------------------------------------------------------------------------------
resource "fabric_workspace_role_assignment" "platform_admin" {
  workspace_id = fabric_workspace.domain.id
  principal = {
    id   = var.platform_admin_group_id
    type = "Group"
  }
  role = "Admin"
}

resource "fabric_workspace_role_assignment" "domain_admin" {
  workspace_id = fabric_workspace.domain.id
  principal = {
    id   = var.domain_admin_group_id
    type = "Group"
  }
  role = "Admin"
}

resource "fabric_workspace_role_assignment" "domain_contributor" {
  workspace_id = fabric_workspace.domain.id
  principal = {
    id   = var.domain_contributor_group_id
    type = "Group"
  }
  role = "Contributor"
}

# ------------------------------------------------------------------------------
# Lakehouse (consumption layer)
# ------------------------------------------------------------------------------
resource "fabric_lakehouse" "domain" {
  display_name = "${local.name_prefix}_lh_${var.domain_name}_prod"
  description  = "${local.domain_label} lakehouse – consumption via OneLake shortcuts"
  workspace_id = fabric_workspace.domain.id
}

# ------------------------------------------------------------------------------
# OneLake Shortcuts (gold layer from core)
# ------------------------------------------------------------------------------
resource "fabric_shortcut" "core_gold" {
  workspace_id = fabric_workspace.domain.id
  item_id      = fabric_lakehouse.domain.id
  path         = "Tables"
  name         = "sc_core_wh_gold"

  target = {
    onelake = {
      workspace_id = var.core_workspace_id
      item_id      = var.core_warehouse_id
      path         = "Tables/gold"
    }
  }
}