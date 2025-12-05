select trade_id
	, count(*) as count_row
from core.fact_trades
group by 1
having count_row > 1