select month
	, token_category
	, count(*) as count_row
from mart.monthly_m1_token_category_retention_rate
group by 1,2
having count_row > 1