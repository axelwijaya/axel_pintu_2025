--truncate staging.stg_p2p_transfers;
--insert into staging.stg_p2p_transfers
select rp.transfer_id			::varchar			as transfer_id
	, rp.sender_id				::varchar			as sender_user_id
	, rp.receiver_id			::varchar			as receiver_user_id
	, rp.token_id				::varchar			as token_id
	, rp.amount					::numeric(38,9)		as transfer_quantity
	, rp.status					::varchar			as transfer_status
	, rp.transfer_created_time	::timestamp 		as transfer_created_utc_datetime
	, rp.transfer_updated_time	::timestamp			as updated_utc_datetime
from raw_transaction.raw_p2p_transfers rp
where 1=1
qualify row_number() over (partition by rp.transfer_id order by rp.transfer_created_time desc) = 1