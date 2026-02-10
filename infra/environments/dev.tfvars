# Development Environment Configuration

environment         = "dev"
resource_group_name = "lbn-rg-fabric-dev"
location            = "eastus"

core_workspace_name = "fabric-core-dev"

# Fabric capacity configuration
# Get the capacity ID by running: az fabric capacity show --name fabric101 --resource-group <rg-name> --query id -o tsv
# Format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Fabric/capacities/fabric101
# TODO: Add your Fabric Capacity full resource ID here
fabric_capacity_id = ""

# Git Integration Configuration
# DISABLED: GitHub requires a Git connection to be created first in Fabric Portal
# To enable: Create connection in Fabric workspace Settings > Git integration, then uncomment below
git_integration_enabled = false
git_provider_type       = "GitHub"
git_owner_name          = "bangelor"
git_repository_name     = "fabric_data_platform"
git_branch_name         = "main"
git_directory_name      = "/fabric/core-dev"
# git_connection_id     = ""  # Required - get GUID from Fabric Portal after creating connection

bu_workspaces = {
  finance = {
    name        = "fabric-finance-dev"
    description = "Finance Business Unit workspace - Development"
  }
  sales = {
    name        = "fabric-sales-dev"
    description = "Sales Business Unit workspace - Development"
  }
  marketing = {
    name        = "fabric-marketing-dev"
    description = "Marketing Business Unit workspace - Development"
  }
}

tags = {
  Environment = "Development"
  ManagedBy   = "Terraform"
  Project     = "FabricDataPlatform"
}
