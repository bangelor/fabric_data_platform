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

# Entra Security Groups (environment-specific)
module "entra_groups" {
  source = "./modules/entra-groups"

  environment      = var.environment
  business_domains = var.business_domains
}

# Core Workspace (only for current environment)
module "core_workspace" {
  source = "./modules/core-workspace"

  workspace_name = "fabric-core-${var.environment}"
  environment    = var.environment
  capacity_id    = var.fabric_capacity_id
}

# Domain Workspace (prod only)
module "domain_workspace" {
  source = "./modules/domain-workspace"
  count  = var.environment == "prod" ? 1 : 0

  workspace_name = "fabric-domain-prod"
  capacity_id    = var.fabric_capacity_id
}
