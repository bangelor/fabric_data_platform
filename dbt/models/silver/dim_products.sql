{{
    config(
        materialized='view',
        schema='silver'
    )
}}

-- Dimension table for products following Kimball methodology
with products as (
    select * from {{ ref('brz_sales__products') }}
),

dim_products as (
    select
        -- Surrogate key (in this case, same as natural key)
        product_id as product_key,
        
        -- Natural key
        product_id,
        
        -- Attributes
        product_name,
        product_category,
        
        -- Pricing attributes
        unit_price,
        cost_per_unit,
        unit_price - cost_per_unit as gross_margin_per_unit,
        case 
            when unit_price > 0 
            then round(((unit_price - cost_per_unit) / unit_price) * 100, 2)
            else 0
        end as margin_percentage,
        
        -- Status
        is_active,
        case when is_active = 1 then 'Active' else 'Inactive' end as active_status,
        
        -- SCD Type 1 metadata
        _loaded_at as effective_date,
        cast('9999-12-31' as date) as expiration_date,
        1 as is_current,
        
        -- Audit columns
        _loaded_at
        
    from products
)

select * from dim_products
