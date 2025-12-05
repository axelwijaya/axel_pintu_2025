select transfer_id
	, count(*) as count_row
from core.fact_p2p_transfers
group by 1
having count_row > 1