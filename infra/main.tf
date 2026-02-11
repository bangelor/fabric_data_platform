# Main Terraform configuration for Fabric Data Platform

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
  admin_group_id       = module.entra_groups.core_admins_id
  contributor_group_id = module.entra_groups.core_contributors_id
}

# Domain Workspaces (one per business domain, prod only)
module "domain_workspace" {
  source   = "./modules/domain-workspace"
  for_each = var.environment == "prod" ? toset(var.business_domains) : []

  workspace_name      = "fabric-${each.value}-${var.environment}"
  domain_name         = each.value
  capacity_id         = var.fabric_capacity_id
  platform_admin_id   = module.entra_groups.platform_admins_id
  core_workspace_id   = module.core_workspace.workspace_id
  core_warehouse_id   = module.core_workspace.warehouse_id
  core_warehouse_name = module.core_workspace.warehouse_name
}
