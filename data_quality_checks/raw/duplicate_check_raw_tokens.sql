select token_id
	, count(*) as count_row
from raw_config.raw_tokens
group by 1
having count_row > 1