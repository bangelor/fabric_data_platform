# Production Environment Configuration

environment         = "prod"
resource_group_name = "rg-fabric-prod"
location            = "eastus"

core_workspace_name = "fabric-core-prod"

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
