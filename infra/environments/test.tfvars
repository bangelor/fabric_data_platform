# Test Environment Configuration

environment         = "test"
resource_group_name = "lbn-rg-fabric-test"
location            = "eastus"

core_workspace_name = "fabric-core-test"

# Fabric capacity configuration
# Get the capacity ID by running: az fabric capacity show --name fabric101 --resource-group <rg-name> --query id -o tsv
# Format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Fabric/capacities/fabric101
fabric_capacity_id = "/subscriptions/8c62f590-4f16-4727-a2a7-f7a0304f308d/resourceGroups/rsg-fabric/providers/Microsoft.Fabric/capacities/fabric101"

# Git Integration Configuration
# DISABLED: GitHub requires a Git connection to be created first in Fabric Portal
# To enable: Create connection in Fabric workspace Settings > Git integration, then uncomment below
git_integration_enabled = false
git_provider_type       = "GitHub"
git_owner_name          = "bangelor"
git_repository_name     = "fabric_data_platform"
git_branch_name         = "main"
git_directory_name      = "/fabric/core-test"
# git_connection_id     = ""  # Required - get GUID from Fabric Portal after creating connection

bu_workspaces = {
  finance = {
    name        = "fabric-finance-test"
    description = "Finance Business Unit workspace - Test"
  }
  sales = {
    name        = "fabric-sales-test"
    description = "Sales Business Unit workspace - Test"
  }
  marketing = {
    name        = "fabric-marketing-test"
    description = "Marketing Business Unit workspace - Test"
  }
}

tags = {
  Environment = "Test"
  ManagedBy   = "Terraform"
  Project     = "FabricDataPlatform"
}
