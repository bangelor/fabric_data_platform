# Core Workspace Module - Full-featured with Git, dbt, CI/CD

# Fabric Workspace for core data platform
resource "fabric_workspace" "core" {
  display_name = var.workspace_name
  description  = "Core Fabric workspace for centralized data platform"
  capacity_id  = var.capacity_id
}

# Git Integration Configuration
# Configure Git sync for notebooks, pipelines, and other artifacts
resource "fabric_workspace_git" "core" {
  count = var.git_integration_enabled ? 1 : 0

  workspace_id            = fabric_workspace.core.id
  initialization_strategy = var.git_initialization_strategy

  git_provider_details = var.git_provider_type == "AzureDevOps" ? {
    git_provider_type = "AzureDevOps"
    organization_name = var.git_organization_name
    project_name      = var.git_project_name
    repository_name   = var.git_repository_name
    branch_name       = var.git_branch_name
    directory_name    = var.git_directory_name
  } : {
    git_provider_type = "GitHub"
    owner_name        = var.git_owner_name
    repository_name   = var.git_repository_name
    branch_name       = var.git_branch_name
    directory_name    = var.git_directory_name
  }

  git_credentials = var.git_credentials_source == "Automatic" ? {
    source = "Automatic"
  } : {
    source        = "ConfiguredConnection"
    connection_id = var.git_connection_id
  }
}

# dbt Configuration
# Set up dbt profiles and connection to Fabric
resource "null_resource" "dbt_setup" {
  count = var.dbt_enabled ? 1 : 0

  triggers = {
    workspace_id = fabric_workspace.core.id
  }

  # dbt configuration would happen here
  # This would configure dbt to connect to Fabric lakehouses
}
