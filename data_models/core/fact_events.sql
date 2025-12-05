--truncate core.fact_events;
--insert into core.fact_events
select sp.transfer_id as event_id
	, sp.sender_user_id as user_id
	, sp.token_id as token_id
	, sp.transfer_status as event_status
	, 'P2P'::varchar as event_category
	, sp.transfer_created_utc_datetime as event_utc_datetime
	, sp.updated_utc_datetime
from staging.stg_p2p_transfers sp
union all
select st.trade_id as event_id
	, st.user_id as user_id
	, st.token_id as token_id
	, st.trade_status as event_status
	, 'TRADE'::varchar as event_category
	, st.trade_created_utc_datetime as event_utc_datetime
	, st.updated_utc_datetime
from staging.stg_trades st