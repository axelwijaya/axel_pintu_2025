--truncate core.fact_trades;
--insert into core.fact_trades
select st.trade_id
	, st.user_id
	, st.token_id
	, st.trade_side
	, st.trade_price_usd
	, st.trade_quantity
	, st.trade_price_usd * st.trade_quantity ::numeric(38,8) as trade_notional_usd
	, st.trade_status
	, st.trade_created_utc_datetime 
	, st.updated_utc_datetime
from staging.stg_trades st