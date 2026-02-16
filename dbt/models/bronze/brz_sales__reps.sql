{{
    config(
        materialized='view',
        schema='bronze'
    )
}}

with source as (
    select * from {{ ref('sales_reps') }}
),

cleaned as (
    select
        -- Primary key
        cast(sales_rep_id as int) as sales_rep_id,
        
        -- Personal attributes
        trim(first_name) as first_name,
        trim(last_name) as last_name,
        trim(first_name) + ' ' + trim(last_name) as full_name,
        lower(trim(email)) as email,
        
        -- Work attributes
        trim(region) as region,
        cast(hire_date as date) as hire_date,
        lower(trim(status)) as status,
        
        -- Metadata
        CAST(SYSDATETIME() AS datetime2(6)) as _loaded_at
        
    from source
    
    -- Basic data quality filters
    where sales_rep_id is not null
        and first_name is not null
        and last_name is not null
)

select * from cleaned
