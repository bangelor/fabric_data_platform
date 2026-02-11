{{
    config(
        materialized='view',
        schema='staging'
    )
}}

with source as (
    select * from {{ source('demo_seeds', 'demo_customers') }}
),

renamed as (
    select
        -- Primary key
        cast(customer_id as int) as customer_id,
        
        -- Customer attributes
        trim(customer_name) as customer_name,
        lower(trim(email)) as email,
        
        -- Temporal
        cast(signup_date as date) as signup_date,
        
        -- Status and classification
        lower(trim(status)) as status,
        trim(country) as country,
        
        -- Metrics
        cast(lifetime_value as decimal(18,2)) as lifetime_value,
        
        -- Metadata
        getdate() as _loaded_at
        
    from source
    
    -- Basic data quality filters
    where customer_id is not null
        and email is not null
        and signup_date is not null
)

select * from renamed
