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
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# Entra Security Groups
module "entra_groups" {
  source = "./modules/entra-groups"

  business_domains = var.business_domains
}

# Core Workspaces (dev, test, prod)
module "core_workspace" {
  source   = "./modules/core-workspace"
  for_each = toset(["dev", "test", "prod"])

  workspace_name = "fabric-core-${each.value}"
  environment    = each.value
  capacity_id    = var.fabric_capacity_id
}

# Domain Workspace (prod only)
module "domain_workspace" {
  source = "./modules/domain-workspace"

  workspace_name = "fabric-domain-prod"
  capacity_id    = var.fabric_capacity_id
}
