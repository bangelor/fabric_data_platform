{{
    config(
        materialized='table',
        schema='marts',
        tags=['certified']
    )
}}

with customer_metrics as (
    select * from {{ ref('int_demo__customer_metrics') }}
),

final as (
    select
        -- Primary key
        customer_id,
        
        -- Dimensions
        customer_name,
        email,
        country,
        status,
        
        -- Dates
        signup_date,
        
        -- Behavioral metrics
        days_since_signup,
        months_since_signup,
        
        -- Financial metrics
        lifetime_value,
        
        -- Segments and classifications
        value_segment,
        engagement_level,
        
        -- Boolean flags
        is_active,
        has_purchased,
        is_churned,
        
        -- Derived metrics for analytics
        case 
            when is_active = 1 and has_purchased = 1 then 'Active Customer'
            when is_active = 1 and has_purchased = 0 then 'New Customer'
            when is_churned = 1 then 'Churned Customer'
            else 'Inactive Customer'
        end as customer_category,
        
        -- Metadata
        _loaded_at as loaded_at,
        SYSDATETIME() as transformed_at
        
    from customer_metrics
)

select * from final
