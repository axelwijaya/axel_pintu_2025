with transacting_users as (
	select date_trunc('month', fe.event_utc_datetime) as month
		, dt.token_category
		, fe.user_id
		, max(fe.updated_utc_datetime) as updated_utc_datetime
	from core.fact_events fe
    left join core.dim_tokens dt
        on fe.token_id = dt.token_id
	where fe.event_status in ('SUCCESS', 'FILLED')
	group by 1,2,3
)
, base as (
	select curr.month
		, curr.token_category
		, curr.user_id as cm_user_id
		, next.user_id as m1_retained_user_id
		, greatest(curr.updated_utc_datetime, next.updated_utc_datetime) as updated_utc_datetime
	from transacting_users curr
	left join transacting_users next
		on curr.month = next.month - interval '1 month'
		and curr.user_id = next.user_id
		and curr.token_category = next.token_category
)
select month
	, token_category
	, count(cm_user_id) as current_month_user_count
	, count(m1_retained_user_id)*1.0/current_month_user_count as m1_token_retention_rate
	, max(updated_utc_datetime) as updated_utc_datetime
from base 
group by 1,2