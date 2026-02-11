# Core Workspace Module - Simplified

# Fabric Workspace for core data platform
resource "fabric_workspace" "core" {
  display_name = var.workspace_name
  description  = "Core Fabric workspace - ${title(var.environment)} environment"
  capacity_id  = var.capacity_id
}

# Assign Admin security group as Workspace Admin
resource "fabric_workspace_role_assignment" "admin" {
  workspace_id = fabric_workspace.core.id
  principal = {
    id   = var.admin_group_id
    type = "Group"
  }
  role = "Admin"
}

# Assign Contributor security group as Workspace Contributor
resource "fabric_workspace_role_assignment" "contributor" {
  workspace_id = fabric_workspace.core.id
  principal = {
    id   = var.contributor_group_id
    type = "Group"
  }
  role = "Contributor"
}

# Lakehouse for core workspace
resource "fabric_lakehouse" "core" {
  display_name = "core_lakehouse_${var.environment}"
  description  = "Core lakehouse for ${var.environment} environment"
  workspace_id = fabric_workspace.core.id
}

# Warehouse for core workspace
resource "fabric_warehouse" "core" {
  display_name = "core_warehouse_${var.environment}"
  description  = "Core warehouse for ${var.environment} environment"
  workspace_id = fabric_workspace.core.id
}

# Create bronze, silver, gold schemas in warehouse
resource "terraform_data" "warehouse_schemas" {
  provisioner "local-exec" {
    command = <<-EOT
      Start-Sleep -Seconds 10
      $token = (az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv)
      $connectionString = "${fabric_workspace.core.properties.connection_string}"
      
      $sqlCommands = @"
      IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
      BEGIN
          EXEC('CREATE SCHEMA bronze');
      END;
      
      IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
      BEGIN
          EXEC('CREATE SCHEMA silver');
      END;
      
      IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
      BEGIN
          EXEC('CREATE SCHEMA gold');
      END;
"@
      
      Invoke-Sqlcmd -ServerInstance $connectionString -Database "${fabric_warehouse.core.display_name}" -AccessToken $token -Query $sqlCommands
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [fabric_warehouse.core]
}
