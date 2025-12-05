select date_trunc('month', event_utc_datetime) event_utc_month
	, token_id
	, count(event_id) as event_count
	, count(case when event_category = 'P2P' then event_id end) as p2p_event_count
	, count(case when event_category = 'TRADE' then event_id end) as trade_event_count
	, max(updated_utc_datetime) as updated_utc_datetime
from core.fact_events
where event_status in ('SUCCESS', 'FILLED')
group by 1,2