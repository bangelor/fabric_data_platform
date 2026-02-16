{{
    config(
        materialized='view',
        schema='silver'
    )
}}

-- Fact table for sales transactions following Kimball methodology
with transactions as (
    select * from {{ ref('brz_sales__transactions') }}
),

fact_sales as (
    select
        -- Fact table primary key
        transaction_id as sales_transaction_key,
        
        -- Foreign keys (dimension references)
        transaction_id,
        product_id as product_key,
        sales_rep_id as sales_rep_key,
        project_id as project_key,
        cast(format(transaction_date, 'yyyyMMdd') as int) as date_key,
        
        -- Degenerate dimensions (transaction-level attributes)
        transaction_date,
        
        -- Measures - Quantities
        quantity,
        
        -- Measures - Amounts
        unit_price,
        discount_percent,
        
        -- Calculated measures - Extended amounts
        quantity * unit_price as gross_amount,
        (quantity * unit_price * discount_percent / 100) as discount_amount,
        (quantity * unit_price) - (quantity * unit_price * discount_percent / 100) as net_amount,
        tax_amount,
        (quantity * unit_price) - (quantity * unit_price * discount_percent / 100) + tax_amount as total_amount,
        
        -- Audit columns
        _loaded_at
        
    from transactions
)

select * from fact_sales
