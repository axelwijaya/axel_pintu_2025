select rt.*
	, count(*) over (partition by rt.token_id)	as count_row
from raw_config.raw_tokens rt
where 1=1
qualify count_row > 1