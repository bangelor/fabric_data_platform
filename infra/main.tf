# Main Terraform configuration for Fabric Data Platform

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Core Workspace - Full-featured with Git, dbt, CI/CD
module "core_workspace" {
  source = "./modules/core-workspace"

  workspace_name      = var.core_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Git integration settings
  git_integration_enabled = true
  
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
  
  # Reference to core workspace for data consumption
  core_workspace_id = module.core_workspace.workspace_id
  
  tags = merge(var.tags, {
    WorkspaceType = "BusinessUnit"
    BusinessUnit  = each.key
  })
}
