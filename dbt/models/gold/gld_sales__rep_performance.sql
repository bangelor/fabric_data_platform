{{
    config(
        materialized='table',
        schema='gold',
        tags=['certified', 'sales']
    )
}}

-- Gold layer: Sales representative performance analytics
with fact_sales as (
    select * from {{ ref('fact_sales') }}
),

dim_sales_reps as (
    select * from {{ ref('dim_sales_reps') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

rep_sales as (
    select
        sr.sales_rep_key,
        sr.sales_rep_id,
        sr.full_name as sales_rep_name,
        sr.first_name,
        sr.last_name,
        sr.email,
        sr.region,
        sr.hire_date,
        sr.tenure_months,
        sr.tenure_years,
        sr.status,
        
        -- Sales volume metrics
        count(distinct f.sales_transaction_key) as total_transactions,
        count(distinct f.project_key) as total_projects,
        count(distinct f.product_key) as total_unique_products,
        sum(f.quantity) as total_units_sold,
        
        -- Revenue metrics
        sum(f.gross_amount) as total_gross_revenue,
        sum(f.discount_amount) as total_discounts,
        sum(f.net_amount) as total_net_revenue,
        sum(f.total_amount) as total_revenue_with_tax,
        
        -- Average metrics
        avg(f.net_amount) as avg_deal_size,
        avg(f.discount_percent) as avg_discount_percent,
        
        -- Profit metrics
        sum(f.quantity * p.cost_per_unit) as total_cost,
        sum(f.net_amount) - sum(f.quantity * p.cost_per_unit) as total_gross_profit,
        case 
            when sum(f.net_amount) > 0 
            then round((sum(f.net_amount) - sum(f.quantity * p.cost_per_unit)) / sum(f.net_amount) * 100, 2)
            else 0
        end as profit_margin_percentage,
        
        -- Activity period
        min(f.transaction_date) as first_sale_date,
        max(f.transaction_date) as last_sale_date,
        datediff(day, min(f.transaction_date), max(f.transaction_date)) as selling_period_days
        
    from fact_sales f
    inner join dim_sales_reps sr on f.sales_rep_key = sr.sales_rep_key
    inner join dim_products p on f.product_key = p.product_key
    group by
        sr.sales_rep_key,
        sr.sales_rep_id,
        sr.full_name,
        sr.first_name,
        sr.last_name,
        sr.email,
        sr.region,
        sr.hire_date,
        sr.tenure_months,
        sr.tenure_years,
        sr.status
),

final as (
    select
        *,
        -- Performance metrics
        case 
            when total_net_revenue >= 200000 then 'Top Performer'
            when total_net_revenue >= 100000 then 'High Performer'
            when total_net_revenue >= 50000 then 'Average Performer'
            else 'Developing'
        end as performance_tier,
        
        -- Rankings
        row_number() over (order by total_net_revenue desc) as revenue_rank,
        row_number() over (order by total_gross_profit desc) as profit_rank,
        row_number() over (order by total_transactions desc) as activity_rank,
        row_number() over (partition by region order by total_net_revenue desc) as region_revenue_rank,
        
        -- Metadata
        CAST(SYSDATETIME() AS datetime2(6)) as transformed_at
        
    from rep_sales
)

select * from final
