{{
    config(
        materialized='table',
        schema='gold',
        tags=['certified', 'sales']
    )
}}

-- Gold layer: Monthly sales summary for executive reporting
with fact_sales as (
    select * from {{ ref('fact_sales') }}
),

dim_date as (
    select * from {{ ref('dim_date') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

monthly_sales as (
    select
        -- Time dimensions
        d.year_number,
        d.year_name,
        d.quarter_number,
        d.quarter_name,
        d.year_quarter,
        d.month_number,
        d.month_name,
        d.year_month,
        
        -- Sales metrics
        count(distinct f.sales_transaction_key) as total_transactions,
        count(distinct f.project_key) as total_projects,
        count(distinct f.sales_rep_key) as total_active_reps,
        count(distinct f.product_key) as total_products_sold,
        sum(f.quantity) as total_units_sold,
        
        -- Revenue metrics
        sum(f.gross_amount) as total_gross_revenue,
        sum(f.discount_amount) as total_discounts,
        sum(f.net_amount) as total_net_revenue,
        sum(f.tax_amount) as total_tax,
        sum(f.total_amount) as total_revenue_with_tax,
        
        -- Average metrics
        avg(f.net_amount) as avg_transaction_value,
        avg(f.discount_percent) as avg_discount_percent,
        
        -- Cost and profit
        sum(f.quantity * p.cost_per_unit) as total_cost,
        sum(f.net_amount) - sum(f.quantity * p.cost_per_unit) as total_gross_profit,
        case 
            when sum(f.net_amount) > 0 
            then round((sum(f.net_amount) - sum(f.quantity * p.cost_per_unit)) / sum(f.net_amount) * 100, 2)
            else 0
        end as profit_margin_percentage
        
    from fact_sales f
    inner join dim_date d on f.date_key = d.date_key
    inner join dim_products p on f.product_key = p.product_key
    group by
        d.year_number,
        d.year_name,
        d.quarter_number,
        d.quarter_name,
        d.year_quarter,
        d.month_number,
        d.month_name,
        d.year_month
),

with_growth as (
    select
        *,
        -- Month-over-month growth
        lag(total_net_revenue, 1) over (order by year_number, month_number) as prev_month_revenue,
        total_net_revenue - lag(total_net_revenue, 1) over (order by year_number, month_number) as mom_revenue_change,
        case 
            when lag(total_net_revenue, 1) over (order by year_number, month_number) > 0
            then round((total_net_revenue - lag(total_net_revenue, 1) over (order by year_number, month_number)) 
                 / lag(total_net_revenue, 1) over (order by year_number, month_number) * 100, 2)
            else 0
        end as mom_revenue_growth_percent,
        
        -- Year-over-year growth
        lag(total_net_revenue, 12) over (order by year_number, month_number) as prev_year_revenue,
        total_net_revenue - lag(total_net_revenue, 12) over (order by year_number, month_number) as yoy_revenue_change,
        case 
            when lag(total_net_revenue, 12) over (order by year_number, month_number) > 0
            then round((total_net_revenue - lag(total_net_revenue, 12) over (order by year_number, month_number)) 
                 / lag(total_net_revenue, 12) over (order by year_number, month_number) * 100, 2)
            else 0
        end as yoy_revenue_growth_percent,
        
        -- Running totals
        sum(total_net_revenue) over (partition by year_number order by month_number) as ytd_revenue,
        sum(total_gross_profit) over (partition by year_number order by month_number) as ytd_profit
        
    from monthly_sales
),

final as (
    select
        *,
        -- Metadata
        CAST(SYSDATETIME() AS datetime2(6)) as transformed_at
        
    from with_growth
)

select * from final
