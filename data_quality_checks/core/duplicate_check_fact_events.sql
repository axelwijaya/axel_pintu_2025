select event_id
	, count(*) as count_row
from core.fact_events
group by 1
having count_row > 1