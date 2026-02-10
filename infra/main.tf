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

# Core Workspaces (dev, test, prod)
module "core_workspace" {
  source   = "./modules/core-workspace"
  for_each = toset(["dev", "test", "prod"])

  workspace_name = "fabric-core-${each.key}"
  environment    = each.key
  capacity_id    = var.fabric_capacity_id
}

# Business Unit Workspace (prod only)
module "business_workspace" {
  source = "./modules/bu-workspace"

  workspace_name = "fabric-business-prod"
  capacity_id    = var.fabric_capacity_id
}
