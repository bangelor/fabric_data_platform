# Development Environment Configuration

environment         = "dev"
resource_group_name = "lbn-rg-fabric-dev"
location            = "eastus"

core_workspace_name = "fabric-core-dev"

# Fabric capacity configuration
fabric_capacity_name = "fabric101"

# Git Integration Configuration
git_integration_enabled = true
git_provider_type       = "GitHub"
git_owner_name          = "bangelor"
git_repository_name     = "fabric_data_platform"
git_branch_name         = "main"
git_directory_name      = "/fabric/core-dev"
git_credentials_source  = "Automatic"
# git_connection_id     = ""  # Only needed if using ConfiguredConnection

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
