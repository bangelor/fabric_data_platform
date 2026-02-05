# Fabric Data Platform

A comprehensive data platform solution using Microsoft Fabric with Terraform infrastructure as code and dbt for data transformations.

## Architecture

This repository implements a hub-and-spoke architecture for Microsoft Fabric:

- **Core Workspace**: Full-featured workspace with Git sync, dbt, and CI/CD pipelines
- **Business Unit Workspaces**: Lightweight consumption-only workspaces that access certified models from the core

## Repository Structure

```
fabric_data_platform/
├── infra/                          # Terraform infrastructure
│   ├── main.tf                     # Main Terraform configuration
│   ├── variables.tf                # Variable definitions
│   ├── providers.tf                # Provider configuration
│   ├── backend.tf                  # Remote state configuration
│   ├── environments/
│   │   ├── dev.tfvars             # Development environment variables
│   │   └── prod.tfvars            # Production environment variables
│   └── modules/
│       ├── core-workspace/         # Core workspace module (Git + dbt)
│       └── bu-workspace/           # BU workspace module (consumption only)
├── dbt/                            # dbt project (core workspace only)
│   ├── dbt_project.yml            # dbt project configuration
│   ├── profiles.yml               # Connection profiles
│   └── models/
│       ├── staging/               # Raw data transformations
│       ├── intermediate/          # Business logic transformations
│       └── marts/                 # Certified models for BU consumption
├── fabric/                         # Fabric artifacts (Git sync)
│   └── core/
│       ├── notebooks/             # Data engineering notebooks
│       └── pipelines/             # Data orchestration pipelines
└── .github/
    └── workflows/
        ├── terraform.yml          # Infrastructure CI/CD
        └── dbt.yml               # dbt CI/CD

```

## Getting Started

### Prerequisites

- Azure subscription with Microsoft Fabric enabled
- Terraform >= 1.0
- Python 3.11+
- dbt-core >= 1.7.0
- Azure CLI
- GitHub repository for CI/CD workflows

### Setup

1. **Bootstrap Azure App Registration (First Time Setup)**
   
   Run the bootstrap script to create an Azure App Registration with federated credentials for GitHub OIDC authentication:
   
   ```bash
   # Linux/Mac
   chmod +x terraform-bootstrap.sh
   ./terraform-bootstrap.sh
   
   # Windows PowerShell
   .\terraform-bootstrap.ps1
   
   # Windows with Git Bash
   bash terraform-bootstrap.sh
   ```
   
   This script will:
   - Create an Azure App Registration
   - Set up federated credentials for GitHub Actions (main, develop, and PR branches)
   - Assign necessary Azure permissions
   - Generate a file with GitHub secrets to configure
   
   Follow the instructions in the generated `github-secrets.txt` file to add secrets to your GitHub repository.

2. **Configure Azure Authentication (Local Development)**
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

3. **Initialize Terraform**
   ```bash
   cd infra
   terraform init
   ```

4. **Deploy Infrastructure**
   ```bash
   # For development
   terraform plan -var-file="environments/dev.tfvars"
   terraform apply -var-file="environments/dev.tfvars"

   # For production
   terraform plan -var-file="environments/prod.tfvars"
   terraform apply -var-file="environments/prod.tfvars"
   ```

5. **Configure dbt**
   ```bash
   cd dbt
   # Update profiles.yml with your Fabric workspace connection details
   dbt debug
   ```

6. **Run dbt Models**
   ```bash
   dbt run
   dbt test
   dbt docs generate
   ```

## Workflows

### Terraform CI/CD
- Automatically runs on changes to `infra/**`
- Validates, plans, and applies infrastructure changes
- Separate workflows for dev and prod environments

### dbt CI/CD
- Runs on changes to `dbt/**`
- Lints SQL with sqlfluff
- Compiles and tests dbt models
- Deploys to dev/prod based on branch

## Data Flow

1. **Ingestion**: Raw data lands in core workspace lakehouse
2. **Staging**: dbt staging models clean and standardize data
3. **Intermediate**: Business logic transformations
4. **Marts**: Certified models ready for BU consumption
5. **Consumption**: BUs access certified models via their workspaces

## Security & Governance

- Core workspace: Full access for data engineering team
- BU workspaces: Read-only access to certified marts
- All transformations tracked in Git
- dbt tests ensure data quality
- Certified models tagged and documented

## Contributing

1. Create a feature branch
2. Make changes
3. Run tests locally
4. Create a pull request
5. CI/CD will automatically validate changes

## License

See [LICENSE](LICENSE) file for details.
