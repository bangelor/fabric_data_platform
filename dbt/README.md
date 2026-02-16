# dbt Models - Fabric Data Platform

This dbt project contains demo data and models for an engineering company's sales operations, following Kimball dimensional modeling methodology.

## Project Structure

### Seeds (Sample Data)
Located in `seeds/`:
- **demo_customers.csv** - Sample customer data for testing
- **sales_products.csv** - Engineering products and services catalog (12 products)
- **sales_reps.csv** - Sales representatives information (8 reps)
- **sales_projects.csv** - Client project engagements (10 projects)
- **sales_transactions.csv** - Individual sales transactions (30 transactions)

### Bronze Layer (Raw Data Ingestion)
Located in `models/bronze/`:
- **brz_demo__customers.sql** - Customer data with basic cleaning
- **brz_sales__products.sql** - Product catalog with type casting
- **brz_sales__reps.sql** - Sales rep data with computed full name
- **brz_sales__projects.sql** - Project data with status normalization
- **brz_sales__transactions.sql** - Transaction data with FK validation

### Silver Layer (Kimball Dimensional Model)
Located in `models/silver/`:

#### Dimension Tables:
- **dim_products.sql** - Product dimension (SCD Type 1)
  - Includes margin calculations and active status
- **dim_sales_reps.sql** - Sales representative dimension (SCD Type 1)
  - Includes tenure calculations and regional assignments
- **dim_projects.sql** - Project dimension (SCD Type 1)
  - Includes duration calculations and status flags
- **dim_date.sql** - Date dimension (Kimball standard)
  - Comprehensive date attributes (day, week, month, quarter, year)
  - Weekend/weekday flags, fiscal year support

#### Fact Table:
- **fact_sales.sql** - Sales transaction fact table
  - Foreign keys to all dimension tables
  - Measures: quantity, gross amount, discount, net amount, tax, total
  - Calculated fields for extended amounts

### Gold Layer (Business-Ready Analytics)
Located in `models/gold/`:

- **gld_sales__product_performance.sql** - Product sales and profitability metrics
  - Revenue and profit by product
  - Performance rankings
  - Margin analysis

- **gld_sales__rep_performance.sql** - Sales rep performance dashboard
  - Revenue and profit by sales rep
  - Performance tiers (Top/High/Average/Developing)
  - Regional rankings

- **gld_sales__project_profitability.sql** - Project financial analysis
  - Revenue vs budget tracking
  - Profitability tiers
  - Industry benchmarking

- **gld_sales__monthly_summary.sql** - Executive monthly reporting
  - Month-over-month growth metrics
  - Year-over-year comparisons
  - Year-to-date cumulative totals

## Data Model Overview

### Kimball Methodology
This project follows Ralph Kimball's dimensional modeling approach:
- **Facts**: Measurable business events (sales transactions)
- **Dimensions**: Context for facts (products, reps, projects, dates)
- **Star Schema**: Fact table at center, dimension tables around it
- **SCD Type 1**: Dimensions overwrite historical values (current state only)

### Business Questions Answered
1. Which products are most profitable?
2. How are sales reps performing by region?
3. Are projects staying within budget?
4. What are the sales trends over time?
5. Which industries are most valuable?

## Running the Models

### Load Seed Data
```bash
dbt seed
```

### Build All Models
```bash
dbt run
```

### Build Specific Layer
```bash
dbt run --select bronze.*
dbt run --select silver.*
dbt run --select gold.*
```

### Run Tests
```bash
dbt test
```

### Generate Documentation
```bash
dbt docs generate
dbt docs serve
```

## Testing Strategy
- **Unique/Not Null**: All primary and foreign keys
- **Relationships**: FK integrity between layers
- **Accepted Values**: Status fields and categorical data
- **Schema Tests**: Defined in `schema.yml` files in each layer

## Data Quality
- Bronze layer: Basic type casting and null filtering
- Silver layer: Business logic, calculations, and SCD structure
- Gold layer: Aggregations, rankings, and growth metrics

## Schema Configuration
Each layer has dedicated schemas:
- Bronze: `bronze` schema
- Silver: `silver` schema  
- Gold: `gold` schema
- Seeds: `dbo` schema
