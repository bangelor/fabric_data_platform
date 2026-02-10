# Production Environment Configuration

environment         = "prod"
resource_group_name = "lbn-rg-fabric-prod"
location            = "eastus"

core_workspace_name = "fabric-core-prod"

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
git_directory_name      = "/fabric/core-prod"
# git_connection_id     = ""  # Required - get GUID from Fabric Portal after creating connection

bu_workspaces = {
  finance = {
    name        = "fabric-finance-prod"
    description = "Finance Business Unit workspace - Production"
  }
  sales = {
    name        = "fabric-sales-prod"
    description = "Sales Business Unit workspace - Production"
  }
  marketing = {
    name        = "fabric-marketing-prod"
    description = "Marketing Business Unit workspace - Production"
  }
}

tags = {
  Environment = "Production"
  ManagedBy   = "Terraform"
  Project     = "FabricDataPlatform"
}
