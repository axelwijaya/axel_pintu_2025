select trade_id
	, count(*) as count_row
from raw_transaction.raw_trades
group by 1
having count_row > 1