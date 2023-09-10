with dates as (
    {{ dbt_date.get_date_dimension("2015-01-01", "2025-01-01") }}
)

select * from dates
order by 1