# Test Environment Configuration

environment         = "test"
resource_group_name = "lbn-rg-fabric-test"
location            = "eastus"

core_workspace_name = "fabric-core-test"

# Fabric capacity configuration
# Get the capacity ID by running: az fabric capacity show --name fabric101 --resource-group <rg-name> --query id -o tsv
# Format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Fabric/capacities/fabric101
fabric_capacity_id = ""  # TODO: Add your Fabric Capacity full resource ID here

# Git Integration Configuration
git_integration_enabled = true
git_provider_type       = "GitHub"
git_owner_name          = "bangelor"
git_repository_name     = "fabric_data_platform"
git_branch_name         = "main"
git_directory_name      = "/fabric/core-test"
git_credentials_source  = "Automatic"
# git_connection_id     = ""  # Only needed if using ConfiguredConnection

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
