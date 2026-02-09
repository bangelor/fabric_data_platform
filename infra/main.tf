# Main Terraform configuration for Fabric Data Platform

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    fabric = {
      source  = "microsoft/fabric"
      version = ">= 0.1.0"
    }
  }
}

# Core Workspace - Full-featured with Git, dbt, CI/CD
module "core_workspace" {
  source = "./modules/core-workspace"

  workspace_name      = var.core_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  capacity_id         = var.fabric_capacity_id != "" ? var.fabric_capacity_id : null

  # Git integration settings
  git_integration_enabled     = var.git_integration_enabled
  git_provider_type           = var.git_provider_type
  git_organization_name       = var.git_organization_name
  git_project_name            = var.git_project_name
  git_owner_name              = var.git_owner_name
  git_repository_name         = var.git_repository_name
  git_branch_name             = var.git_branch_name
  git_directory_name          = var.git_directory_name
  git_initialization_strategy = var.git_initialization_strategy
  git_credentials_source      = var.git_credentials_source
  git_connection_id           = var.git_connection_id

  # dbt settings
  dbt_enabled = true

  tags = merge(var.tags, {
    WorkspaceType = "Core"
  })
}

# Business Unit Workspaces - Lightweight consumption only
module "bu_workspaces" {
  source   = "./modules/bu-workspace"
  for_each = var.bu_workspaces

  workspace_name      = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  capacity_id         = var.fabric_capacity_id != "" ? var.fabric_capacity_id : null

  # Reference to core workspace for data consumption
  core_workspace_id = module.core_workspace.workspace_id

  tags = merge(var.tags, {
    WorkspaceType = "BusinessUnit"
    BusinessUnit  = each.key
  })
}
