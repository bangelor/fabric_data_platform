{{
    config(
        materialized='view',
        schema='bronze'
    )
}}

with source as (
    select * from {{ ref('sales_transactions') }}
),

cleaned as (
    select
        -- Primary key
        cast(transaction_id as int) as transaction_id,
        
        -- Foreign keys
        cast(project_id as int) as project_id,
        cast(product_id as int) as product_id,
        cast(sales_rep_id as int) as sales_rep_id,
        
        -- Temporal
        cast(transaction_date as date) as transaction_date,
        
        -- Transaction details
        cast(quantity as int) as quantity,
        cast(unit_price as decimal(18,2)) as unit_price,
        cast(discount_percent as decimal(5,2)) as discount_percent,
        cast(tax_amount as decimal(18,2)) as tax_amount,
        
        -- Metadata
        CAST(SYSDATETIME() AS datetime2(6)) as _loaded_at
        
    from source
    
    -- Basic data quality filters
    where transaction_id is not null
        and project_id is not null
        and product_id is not null
        and sales_rep_id is not null
        and transaction_date is not null
)

select * from cleaned
