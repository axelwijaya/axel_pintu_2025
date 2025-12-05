select trade_month
	, ntile_group
	, count(*) as count_row
from mart.monthly_trade_volume_growth_decomposition
group by 1,2
having count_row > 1