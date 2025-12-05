select event_utc_month
	, token_id
	, count(*) as count_row
from mart.monthly_event_count_per_token
group by 1,2
having count_row > 1