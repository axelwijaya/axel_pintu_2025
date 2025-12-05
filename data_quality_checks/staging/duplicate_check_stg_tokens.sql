select token_id
	, count(*) as count_row
from staging.stg_tokens
group by 1
having count_row > 1