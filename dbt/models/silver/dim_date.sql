{{
    config(
        materialized='view',
        schema='silver'
    )
}}

-- Date dimension following Kimball methodology
-- Generate dates from 2020-01-01 to 2030-12-31
with date_spine as (
    select
        dateadd(day, number, '2020-01-01') as date_day
    from (
        select top 4018 row_number() over (order by (select null)) - 1 as number
        from sys.all_objects a
        cross join sys.all_objects b
    ) numbers
    where dateadd(day, number, '2020-01-01') <= '2030-12-31'
),

dim_date as (
    select
        -- Surrogate key (YYYYMMDD format)
        cast(format(date_day, 'yyyyMMdd') as int) as date_key,
        
        -- Natural key
        date_day as date_value,
        
        -- Day attributes
        day(date_day) as day_of_month,
        datename(weekday, date_day) as day_name,
        datename(dw, date_day) as day_name_short,
        datepart(dw, date_day) as day_of_week,
        datepart(dy, date_day) as day_of_year,
        
        -- Week attributes
        datepart(week, date_day) as week_of_year,
        case when datepart(dw, date_day) in (1, 7) then 1 else 0 end as is_weekend,
        case when datepart(dw, date_day) not in (1, 7) then 1 else 0 end as is_weekday,
        
        -- Month attributes
        month(date_day) as month_number,
        datename(month, date_day) as month_name,
        left(datename(month, date_day), 3) as month_name_short,
        format(date_day, 'yyyy-MM') as year_month,
        
        -- Quarter attributes
        datepart(quarter, date_day) as quarter_number,
        'Q' + cast(datepart(quarter, date_day) as varchar) as quarter_name,
        cast(year(date_day) as varchar) + '-Q' + cast(datepart(quarter, date_day) as varchar) as year_quarter,
        
        -- Year attributes
        year(date_day) as year_number,
        cast(year(date_day) as varchar) as year_name,
        
        -- Fiscal year (assuming fiscal year starts in January)
        case
            when month(date_day) >= 1 then year(date_day)
            else year(date_day) - 1
        end as fiscal_year,
        
        -- First/last day flags
        case when day(date_day) = 1 then 1 else 0 end as is_first_day_of_month,
        case when dateadd(day, 1, date_day) = dateadd(month, 1, dateadd(day, 1 - day(date_day), date_day)) then 1 else 0 end as is_last_day_of_month,
        
        -- Special date flags
        case when date_day = CAST(SYSDATETIME() AS date) then 1 else 0 end as is_today
        
    from date_spine
)

select * from dim_date
