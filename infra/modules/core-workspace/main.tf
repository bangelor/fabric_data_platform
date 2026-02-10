# Core Workspace Module - Simplified

# Fabric Workspace for core data platform
resource "fabric_workspace" "core" {
  display_name = var.workspace_name
  description  = "Core Fabric workspace - ${title(var.environment)} environment"
  capacity_id  = var.capacity_id
}
