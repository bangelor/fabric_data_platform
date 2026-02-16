{{
    config(
        materialized='table',
        schema='gold',
        tags=['certified', 'sales']
    )
}}

-- Gold layer: Product performance analytics
with fact_sales as (
    select * from {{ ref('fact_sales') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

product_sales as (
    select
        p.product_key,
        p.product_id,
        p.product_name,
        p.product_category,
        p.unit_price as list_price,
        p.cost_per_unit,
        p.gross_margin_per_unit as list_margin_per_unit,
        p.margin_percentage as list_margin_percentage,
        p.is_active,
        
        -- Sales volume metrics
        count(distinct f.sales_transaction_key) as total_transactions,
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
        
        -- Calculated profit metrics (using cost from product dimension)
        sum(f.quantity * p.cost_per_unit) as total_cost,
        sum(f.net_amount) - sum(f.quantity * p.cost_per_unit) as total_gross_profit,
        case 
            when sum(f.net_amount) > 0 
            then round((sum(f.net_amount) - sum(f.quantity * p.cost_per_unit)) / sum(f.net_amount) * 100, 2)
            else 0
        end as profit_margin_percentage,
        
        -- First and last sale dates
        min(f.transaction_date) as first_sale_date,
        max(f.transaction_date) as last_sale_date,
        datediff(day, min(f.transaction_date), max(f.transaction_date)) as days_on_market
        
    from fact_sales f
    inner join dim_products p on f.product_key = p.product_key
    group by
        p.product_key,
        p.product_id,
        p.product_name,
        p.product_category,
        p.unit_price,
        p.cost_per_unit,
        p.gross_margin_per_unit,
        p.margin_percentage,
        p.is_active
),

final as (
    select
        *,
        -- Ranking
        row_number() over (order by total_net_revenue desc) as revenue_rank,
        row_number() over (order by total_units_sold desc) as volume_rank,
        row_number() over (order by total_gross_profit desc) as profit_rank,
        
        -- Metadata
        CAST(SYSDATETIME() AS datetime2(6)) as transformed_at
        
    from product_sales
)

select * from final
