with latest_transaction as (
	select fe.user_id 
		, max(fe.event_utc_datetime) as latest_transaction_utc_datetime
	from core.fact_events fe
	where fe.event_status in ('FILLED', 'SUCCESS')
	group by 1
)
, base as (
	select du.user_id
		, du.user_first_p2p_utc_datetime
		, du.user_first_trade_utc_datetime 
		, extract(day from du.user_first_trade_utc_datetime - du.user_first_p2p_utc_datetime) as days_until_first_trade
		, lt.latest_transaction_utc_datetime
		, extract(day from now()::timestamp - lt.latest_transaction_utc_datetime) as days_since_latest_transaction
		, case
			when days_since_latest_transaction >= 90 then 'CHURNED'
			else 'ACTIVE'
			end as current_status
		, case
			when days_until_first_trade <= 7 then 'CONVERT D7'
			when days_until_first_trade <= 30 then 'CONVERT D30'
			when days_until_first_trade <= 90 then 'CONVERT D90'
			when days_until_first_trade > 90 then 'CONVERT >D90'
			when extract(day from now()::timestamp - du.user_first_p2p_utc_datetime) <= 90 and days_until_first_trade is null then 'NOT CONVERT <=D90'
			when extract(day from now()::timestamp - du.user_first_p2p_utc_datetime) > 90 and days_until_first_trade is null then 'NOT CONVERT >D90'
			else null
			end as convert_to_trade_category
	from core.dim_users du
	left join latest_transaction lt on du.user_id = lt.user_id
	where du.user_first_transaction_category = 'P2P'
)
select date_trunc('month', user_first_p2p_utc_datetime) first_p2p_transfer_month
	, count(*) as user_count
	, count(case when convert_to_trade_category = 'CONVERT D7' then 1 else null end)*1.0/user_count as convert_d7_rate
	, count(case when convert_to_trade_category = 'CONVERT D30' then 1 else null end)*1.0/user_count as convert_d30_rate
	, count(case when convert_to_trade_category = 'CONVERT D90' then 1 else null end)*1.0/user_count as convert_d90_rate
	, count(case when convert_to_trade_category = 'CONVERT >D90' then 1 else null end)*1.0/user_count as convert_after_d90_rate
	, count(case when convert_to_trade_category = 'NOT CONVERT >D90' then 1 else null end)*1.0/user_count as not_convert_after_d90_rate
	, count(case when current_status = 'CHURNED' then 1 else null end)*1.0/user_count as churn_rate
from base
group by 1