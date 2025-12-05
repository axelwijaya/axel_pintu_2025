--truncate staging.stg_trades;
--insert into staging.stg_trades
select rt.trade_id						::varchar		as trade_id
	, rt.user_id						::varchar		as user_id
	, rt.token_id						::varchar		as token_id
	, rt.side							::varchar		as trade_side
	, rt.price_usd						::numeric(38,9)	as trade_price_usd
	, rt.quantity						::numeric(38,9)	as trade_quantity
	, rt.status							::varchar		as trade_status
	, rt.trade_created_time				::timestamp		as trade_created_utc_datetime
	, rt.trade_updated_time				::timestamp		as updated_utc_datetime
from raw_transaction.raw_trades rt
where 1=1
qualify row_number() over (partition by rt.trade_id order by rt.trade_created_time desc) = 1