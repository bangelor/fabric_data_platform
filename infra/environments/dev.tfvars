# Development Environment Configuration

environment         = "dev"
resource_group_name = "rg-fabric-dev"
location            = "eastus"

core_workspace_name = "fabric-core-dev"

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
