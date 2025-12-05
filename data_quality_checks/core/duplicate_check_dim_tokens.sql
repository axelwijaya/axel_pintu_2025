select token_id
	, count(*) as count_row
from core.dim_tokens
group by 1
having count_row > 1