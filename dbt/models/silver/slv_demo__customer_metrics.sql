{{
    config(
        materialized='view',
        schema='silver'
    )
}}

with customers as (
    select * from {{ ref('brz_demo__customers') }}
),

customer_metrics as (
    select
        -- Primary key
        customer_id,
        
        -- Customer attributes
        customer_name,
        email,
        country,
        status,
        
        -- Temporal
        signup_date,
        
        -- Calculated temporal metrics
        datediff(day, signup_date, CAST(SYSDATETIME() AS date)) as days_since_signup,
        datediff(day, signup_date, CAST(SYSDATETIME() AS date)) / 30 as months_since_signup,
        
        -- Financial metrics
        lifetime_value,
        
        -- Segmentation logic
        case
            when lifetime_value >= 2000 then 'high_value'
            when lifetime_value >= 1000 then 'medium_value'
            when lifetime_value > 0 then 'low_value'
            else 'no_value'
        end as value_segment,
        
        -- Engagement classification
        case
            when status = 'active' and lifetime_value > 1000 then 'engaged'
            when status = 'active' and lifetime_value > 0 then 'moderate'
            when status = 'active' and lifetime_value = 0 then 'new'
            when status = 'inactive' then 'at_risk'
            when status = 'churned' then 'lost'
            else 'unknown'
        end as engagement_level,
        
        -- Flags
        case when status = 'active' then 1 else 0 end as is_active,
        case when lifetime_value > 0 then 1 else 0 end as has_purchased,
        case when status = 'churned' then 1 else 0 end as is_churned,
        
        -- Metadata
        _loaded_at
        
    from customers
)

select * from customer_metrics
