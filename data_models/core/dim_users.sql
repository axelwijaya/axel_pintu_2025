--truncate core.dim_users;
--insert into core.dim_users
with first_p2p as (
select sp.sender_user_id as user_id
	, sp.token_id
	, sp.transfer_created_utc_datetime as user_first_p2p_utc_datetime
	, sp.updated_utc_datetime
from staging.stg_p2p_transfers sp
where sp.transfer_status = 'SUCCESS'
qualify row_number() over (partition by sp.sender_user_id order by sp.transfer_created_utc_datetime asc) = 1
)
, first_trade as (
select st.user_id
	, st.token_id
	, st.trade_created_utc_datetime as user_first_trade_utc_datetime
	, st.updated_utc_datetime
from staging.stg_trades st
where st.trade_status = 'FILLED'
qualify row_number() over (partition by st.user_id order by st.trade_created_utc_datetime asc) = 1
)
select su.user_id
	, su.user_region
	, su.user_signup_date
	, fp.user_first_p2p_utc_datetime
	, ft.user_first_trade_utc_datetime
	, case
		when least(fp.user_first_p2p_utc_datetime, ft.user_first_trade_utc_datetime) = fp.user_first_p2p_utc_datetime then 'P2P'
		when least(fp.user_first_p2p_utc_datetime, ft.user_first_trade_utc_datetime) = ft.user_first_trade_utc_datetime then 'TRADE'
		else null
		end as user_first_transaction_category
	, case
		when user_first_transaction_category = 'P2P' then fp.token_id
		when user_first_transaction_category = 'TRADE' then ft.token_id
		end user_first_transaction_token_id
	, greatest(su.updated_utc_datetime, fp.updated_utc_datetime, ft.updated_utc_datetime) as updated_utc_datetime
from staging.stg_users su
left join first_p2p fp		on fp.user_id = su.user_id
left join first_trade ft	on ft.user_id = su.user_id