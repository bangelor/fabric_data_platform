# Business Unit Workspace Module - Simplified

# Fabric Workspace for business unit
resource "fabric_workspace" "bu" {
  display_name = var.workspace_name
  description  = "Business unit workspace for data consumption"
  capacity_id  = var.capacity_id
}
