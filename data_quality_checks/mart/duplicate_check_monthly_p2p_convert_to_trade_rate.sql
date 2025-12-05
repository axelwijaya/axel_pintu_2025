select first_p2p_transfer_month
	, count(*) as count_row
from mart.monthly_p2p_convert_to_trade_rate
group by 1
having count_row > 1