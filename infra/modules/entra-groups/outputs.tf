# Platform Groups
output "platform_admins_id" {
  description = "Object ID of Platform Admins group"
  value       = azuread_group.platform_admins.id
}

output "cicd_approvers_id" {
  description = "Object ID of CI/CD Approvers group"
  value       = azuread_group.cicd_approvers.id
}

# Core Workspace Groups (maps keyed by environment)
output "core_admins_ids" {
  description = "Map of Core Admin group IDs by environment"
  value = {
    for env, group in azuread_group.core_admins : env => group.id
  }
}

output "core_contributors_ids" {
  description = "Map of Core Contributor group IDs by environment"
  value = {
    for env, group in azuread_group.core_contributors : env => group.id
  }
}

# Business Workspace Groups (maps keyed by domain)
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

# App Audience Groups (maps keyed by domain)
output "app_viewers_domain_ids" {
  description = "Map of App Viewer group IDs by domain"
  value = {
    for domain, group in azuread_group.app_viewers_domain : domain => group.id
  }
}

output "app_viewers_org_id" {
  description = "Object ID of Org Dashboard Viewers group"
  value       = azuread_group.app_viewers_org.id
}

# CI/CD Service Principal
output "cicd_app_id" {
  description = "Application (Client) ID of CI/CD Service Principal"
  value       = azuread_application.cicd.client_id
}

output "cicd_sp_id" {
  description = "Object ID of CI/CD Service Principal"
  value       = azuread_service_principal.cicd.id
}

output "cicd_sp_object_id" {
  description = "Service Principal Object ID for role assignments"
  value       = azuread_service_principal.cicd.object_id
}
