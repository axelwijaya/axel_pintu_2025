select ru.*
	, count(*) over (partition by ru.user_id)	as count_row
from raw_kyc.raw_users ru
where 1=1
qualify count_row > 1