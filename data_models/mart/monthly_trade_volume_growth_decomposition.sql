with base as (
select date_trunc('month', ft.trade_created_utc_datetime) as month
	, user_id
	, sum(ft.trade_notional_usd) as trade_volume
	, max(ft.updated_utc_datetime) as updated_utc_datetime
from core.fact_trades ft
where trade_status = 'FILLED'
group by 1,2
)
, month_to_month as (
select coalesce(curr.month, prev.month + interval '1 month') as trade_month
	, coalesce(curr.user_id, prev.user_id) as user_id
	, coalesce(curr.trade_volume, 0) as current_month_trade_volume
	, coalesce(prev.trade_volume, 0) as previous_month_trade_volume
	, current_month_trade_volume - previous_month_trade_volume as trade_volume_growth
	, greatest(curr.updated_utc_datetime, prev.updated_utc_datetime) as updated_utc_datetime
from base curr
full join base prev
	on curr.month = prev.month + interval '1 month'
	and curr.user_id = prev.user_id
where trade_month <= date_trunc('month', current_date)
)
, ntile_group as (
select trade_month
	, ntile(5) over (partition by trade_month order by trade_volume_growth) as ntile_group
	, trade_volume_growth
	, updated_utc_datetime
from month_to_month
)
select trade_month
	, ntile_group
	, sum(trade_volume_growth) as trade_volume_growth
	, count(*) as user_count
	, max(updated_utc_datetime) as updated_utc_datetime
from ntile_group
group by 1,2