# Platform Groups (created only in dev environment)
output "platform_admins_id" {
  description = "Object ID of Platform Admins group"
  value       = length(azuread_group.platform_admins) > 0 ? azuread_group.platform_admins[0].id : null
}

output "cicd_approvers_id" {
  description = "Object ID of CI/CD Approvers group"
  value       = length(azuread_group.cicd_approvers) > 0 ? azuread_group.cicd_approvers[0].id : null
}

# Core Workspace Groups (for current environment only)
output "core_admins_id" {
  description = "Object ID of Core Admin group for current environment"
  value       = azuread_group.core_admins.id
}

output "core_contributors_id" {
  description = "Object ID of Core Contributor group for current environment"
  value       = azuread_group.core_contributors.id
}

# Business Workspace Groups (maps keyed by domain, prod only)
output "business_admins_ids" {
  description = "Map of Business Admin group IDs by domain"
  value = {
    for domain, group in azuread_group.business_admins : domain => group.id
  }
}

output "business_contributors_ids" {
  description = "Map of Business Contributor group IDs by domain"
  value = {
    for domain, group in azuread_group.business_contributors : domain => group.id
  }
}

# App Audience Groups (maps keyed by domain, prod only)
output "app_viewers_domain_ids" {
  description = "Map of App Viewer group IDs by domain"
  value = {
    for domain, group in azuread_group.app_viewers_domain : domain => group.id
  }
}

output "app_viewers_org_id" {
  description = "Object ID of Organization-wide App Viewers group"
  value       = length(azuread_group.app_viewers_org) > 0 ? azuread_group.app_viewers_org[0].id : null
}
