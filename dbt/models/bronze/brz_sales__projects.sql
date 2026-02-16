{{
    config(
        materialized='view',
        schema='bronze'
    )
}}

with source as (
    select * from {{ ref('sales_projects') }}
),

cleaned as (
    select
        -- Primary key
        cast(project_id as int) as project_id,
        
        -- Project attributes
        trim(project_name) as project_name,
        trim(client_name) as client_name,
        trim(industry) as industry,
        
        -- Temporal
        cast(start_date as date) as start_date,
        cast(end_date as date) as end_date,
        
        -- Status
        lower(trim(project_status)) as project_status,
        
        -- Financial
        cast(total_budget as decimal(18,2)) as total_budget,
        
        -- Metadata
        CAST(SYSDATETIME() AS datetime2(6)) as _loaded_at
        
    from source
    
    -- Basic data quality filters
    where project_id is not null
        and project_name is not null
)

select * from cleaned
