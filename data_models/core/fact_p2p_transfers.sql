--truncate core.fact_p2p_transfers;
--insert into core.fact_p2p_transfers
select sp.transfer_id
	, sp.sender_user_id
	, sp.receiver_user_id
	, sp.token_id
	, sp.transfer_quantity
	, sp.transfer_status
	, sp.transfer_created_utc_datetime
	, sp.updated_utc_datetime
from staging.stg_p2p_transfers sp