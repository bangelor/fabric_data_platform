{{
    config(
        materialized='table',
        schema='gold',
        tags=['certified', 'sales']
    )
}}

-- Gold layer: Project profitability analytics
with fact_sales as (
    select * from {{ ref('fact_sales') }}
),

dim_projects as (
    select * from {{ ref('dim_projects') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

project_financials as (
    select
        pr.project_key,
        pr.project_id,
        pr.project_name,
        pr.client_name,
        pr.industry,
        pr.start_date,
        pr.end_date,
        pr.project_duration_days,
        pr.project_duration_months,
        pr.project_status,
        pr.status_description,
        pr.total_budget,
        pr.is_completed,
        pr.is_active,
        
        -- Sales activity metrics
        count(distinct f.sales_transaction_key) as total_transactions,
        count(distinct f.product_key) as total_unique_products,
        sum(f.quantity) as total_units_sold,
        
        -- Revenue metrics
        sum(f.gross_amount) as total_gross_revenue,
        sum(f.discount_amount) as total_discounts,
        sum(f.net_amount) as total_net_revenue,
        sum(f.total_amount) as total_revenue_with_tax,
        
        -- Cost and profit metrics
        sum(f.quantity * p.cost_per_unit) as total_cost,
        sum(f.net_amount) - sum(f.quantity * p.cost_per_unit) as total_gross_profit,
        case 
            when sum(f.net_amount) > 0 
            then round((sum(f.net_amount) - sum(f.quantity * p.cost_per_unit)) / sum(f.net_amount) * 100, 2)
            else 0
        end as profit_margin_percentage,
        
        -- Budget vs actual
        pr.total_budget - sum(f.net_amount) as budget_variance,
        case 
            when pr.total_budget > 0 
            then round((sum(f.net_amount) / pr.total_budget) * 100, 2)
            else 0
        end as budget_utilization_percentage,
        
        -- Activity dates
        min(f.transaction_date) as first_transaction_date,
        max(f.transaction_date) as last_transaction_date
        
    from fact_sales f
    inner join dim_projects pr on f.project_key = pr.project_key
    inner join dim_products p on f.product_key = p.product_key
    group by
        pr.project_key,
        pr.project_id,
        pr.project_name,
        pr.client_name,
        pr.industry,
        pr.start_date,
        pr.end_date,
        pr.project_duration_days,
        pr.project_duration_months,
        pr.project_status,
        pr.status_description,
        pr.total_budget,
        pr.is_completed,
        pr.is_active
),

final as (
    select
        *,
        -- Profitability classification
        case 
            when profit_margin_percentage >= 50 then 'Highly Profitable'
            when profit_margin_percentage >= 30 then 'Profitable'
            when profit_margin_percentage >= 10 then 'Marginally Profitable'
            when profit_margin_percentage > 0 then 'Low Margin'
            else 'Loss'
        end as profitability_tier,
        
        -- Budget performance
        case
            when budget_utilization_percentage > 100 then 'Over Budget'
            when budget_utilization_percentage >= 80 then 'On Track'
            when budget_utilization_percentage >= 50 then 'Under Utilized'
            else 'Low Utilization'
        end as budget_status,
        
        -- Rankings
        row_number() over (order by total_net_revenue desc) as revenue_rank,
        row_number() over (order by total_gross_profit desc) as profit_rank,
        row_number() over (partition by industry order by total_net_revenue desc) as industry_revenue_rank,
        
        -- Metadata
        CAST(SYSDATETIME() AS datetime2(6)) as transformed_at
        
    from project_financials
)

select * from final
