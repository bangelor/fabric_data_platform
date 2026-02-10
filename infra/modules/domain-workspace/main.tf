# Domain Workspace Module - Simplified

# Fabric Workspace for domain
resource "fabric_workspace" "domain" {
  display_name = var.workspace_name
  description  = "Domain workspace for data consumption"
  capacity_id  = var.capacity_id
}
