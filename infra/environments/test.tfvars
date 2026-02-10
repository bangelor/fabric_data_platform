# Test Environment Configuration

environment         = "test"
resource_group_name = "lbn-rg-fabric-test"
location            = "eastus"

core_workspace_name = "fabric-core-test"

# Fabric capacity configuration
# Capacity UUID from Fabric Portal: Settings > License Configuration > Capacity ID
fabric_capacity_id = "01CA0BA8-FCEE-4FB2-A296-C131D0DEC5B6"

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
