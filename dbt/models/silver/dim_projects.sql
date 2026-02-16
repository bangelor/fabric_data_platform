{{
    config(
        materialized='view',
        schema='silver'
    )
}}

-- Dimension table for projects following Kimball methodology
with projects as (
    select * from {{ ref('brz_sales__projects') }}
),

dim_projects as (
    select
        -- Surrogate key (in this case, same as natural key)
        project_id as project_key,
        
        -- Natural key
        project_id,
        
        -- Attributes
        project_name,
        client_name,
        industry,
        
        -- Temporal attributes
        start_date,
        end_date,
        datediff(day, start_date, coalesce(end_date, CAST(SYSDATETIME() AS date))) as project_duration_days,
        datediff(month, start_date, coalesce(end_date, CAST(SYSDATETIME() AS date))) as project_duration_months,
        
        -- Status
        project_status,
        case 
            when project_status = 'completed' then 'Completed'
            when project_status = 'in_progress' then 'In Progress'
            when project_status = 'planned' then 'Planned'
            when project_status = 'cancelled' then 'Cancelled'
            else 'Unknown'
        end as status_description,
        
        -- Financial
        total_budget,
        
        -- Flags
        case when project_status = 'completed' then 1 else 0 end as is_completed,
        case when project_status = 'in_progress' then 1 else 0 end as is_active,
        
        -- SCD Type 1 metadata
        _loaded_at as effective_date,
        cast('9999-12-31' as date) as expiration_date,
        1 as is_current,
        
        -- Audit columns
        _loaded_at
        
    from projects
)

select * from dim_projects
