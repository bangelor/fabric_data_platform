{{
    config(
        materialized='view',
        schema='silver'
    )
}}

-- Dimension table for sales representatives following Kimball methodology
with sales_reps as (
    select * from {{ ref('brz_sales__reps') }}
),

dim_sales_reps as (
    select
        -- Surrogate key (in this case, same as natural key)
        sales_rep_id as sales_rep_key,
        
        -- Natural key
        sales_rep_id,
        
        -- Attributes
        first_name,
        last_name,
        full_name,
        email,
        region,
        
        -- Temporal attributes
        hire_date,
        datediff(month, hire_date, CAST(SYSDATETIME() AS date)) as tenure_months,
        datediff(year, hire_date, CAST(SYSDATETIME() AS date)) as tenure_years,
        
        -- Status
        status,
        case 
            when status = 'active' then 'Active'
            when status = 'inactive' then 'Inactive'
            else 'Unknown'
        end as status_description,
        
        -- SCD Type 1 metadata
        _loaded_at as effective_date,
        cast('9999-12-31' as date) as expiration_date,
        1 as is_current,
        
        -- Audit columns
        _loaded_at
        
    from sales_reps
)

select * from dim_sales_reps
