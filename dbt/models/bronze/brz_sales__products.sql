{{
    config(
        materialized='view',
        schema='bronze'
    )
}}

with source as (
    select * from {{ ref('sales_products') }}
),

cleaned as (
    select
        -- Primary key
        cast(product_id as int) as product_id,
        
        -- Product attributes
        trim(product_name) as product_name,
        trim(product_category) as product_category,
        
        -- Pricing
        cast(unit_price as decimal(18,2)) as unit_price,
        cast(cost_per_unit as decimal(18,2)) as cost_per_unit,
        
        -- Status
        case 
            when lower(trim(cast(is_active as varchar))) in ('true', '1', 'yes') then 1
            else 0
        end as is_active,
        
        -- Metadata
        CAST(SYSDATETIME() AS datetime2(6)) as _loaded_at
        
    from source
    
    -- Basic data quality filters
    where product_id is not null
        and product_name is not null
)

select * from cleaned
