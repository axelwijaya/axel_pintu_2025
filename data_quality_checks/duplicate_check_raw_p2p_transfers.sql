select rp.*
	, count(*) over (partition by rp.transfer_id)	as count_row
from raw_transaction.raw_p2p_transfers rp
where 1=1
qualify count_row > 1