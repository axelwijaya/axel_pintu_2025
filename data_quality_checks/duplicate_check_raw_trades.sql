select rt.*
	, count(*) over (partition by rt.trade_id)	as count_row
from raw_transaction.raw_trades rt
where 1=1
qualify count_row > 1