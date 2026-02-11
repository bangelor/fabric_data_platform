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

# Root domain for the data platform
resource "fabric_domain" "platform" {
  display_name       = "Data Platform"
  description        = "Root domain for the Fabric data platform"
  contributors_scope = "AdminsOnly"
}

# Core domain for all core workspaces (dev, test, prod)
resource "fabric_domain" "core" {
  display_name     = "Core"
  description      = "Core domain containing platform workspaces for all environments"
  parent_domain_id = fabric_domain.platform.id
}

# Business domains (one per business domain, for prod only)
resource "fabric_domain" "business" {
  for_each = var.environment == "prod" ? toset(var.business_domains) : []

  display_name     = title(each.value)
  description      = "${title(each.value)} domain for business-specific data products"
  parent_domain_id = fabric_domain.platform.id
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

  workspace_name       = "fabric-core-${var.environment}"
  environment          = var.environment
  capacity_id          = var.fabric_capacity_id
  domain_id            = fabric_domain.core.id
  admin_group_id       = module.entra_groups.core_admins_id
  contributor_group_id = module.entra_groups.core_contributors_id

  depends_on = [module.entra_groups, fabric_domain.core]
}

# Domain Workspaces (one per business domain, prod only)
module "domain_workspace" {
  source   = "./modules/domain-workspace"
  for_each = var.environment == "prod" ? toset(var.business_domains) : []

  workspace_name      = "fabric-${each.value}-${var.environment}"
  capacity_id         = var.fabric_capacity_id
  domain_id           = fabric_domain.business[each.value].id
  platform_admin_id   = module.entra_groups.platform_admins_id
  core_workspace_id   = module.core_workspace.workspace_id
  core_warehouse_id   = module.core_workspace.warehouse_id
  core_warehouse_name = module.core_workspace.warehouse_name

  depends_on = [module.entra_groups, module.core_workspace, fabric_domain.business]
}
