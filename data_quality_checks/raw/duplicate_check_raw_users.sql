select user_id
	, count(*) as count_row
from raw_kyc.raw_users
group by 1
having count_row > 1