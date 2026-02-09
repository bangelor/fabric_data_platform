# Business Unit Workspace Module - Lightweight consumption only

# Fabric Workspace for business unit
resource "fabric_workspace" "bu" {
  display_name = var.workspace_name
  description  = "Business unit workspace for data consumption"
  capacity_id  = var.capacity_id
}

# Configure access to core workspace certified models
# This would set up proper permissions and data sharing
resource "null_resource" "core_workspace_access" {
  triggers = {
    bu_workspace_id   = fabric_workspace.bu.id
    core_workspace_id = var.core_workspace_id
  }

  # Access configuration would happen here using Fabric REST API
  # - Read access to certified models in core workspace
  # - Connection to core data lakehouse
  # - Consumption permissions only (no write)
}
