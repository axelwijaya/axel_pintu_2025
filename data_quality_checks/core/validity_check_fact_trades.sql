select ft.trade_id
	, case
		when ft.trade_id is null then 0
		else 1
		end as trade_id_validity
	, case
		when du.user_id is null then 0
		else 1
		end as user_id_validity
	, case
		when dt.token_id is null then 0
		else 1
		end as token_id_validity
	, case
		when ft.trade_side not in ('BUY', 'SELL')
			or ft.trade_side is null then 0
		else 1
		end as trade_side_validity
	, case
		when ft.trade_price_usd < 0
			or ft.trade_price_usd is null then 0
		else 1
		end as trade_price_usd_validity
	, case
		when ft.trade_quantity < 0
			or ft.trade_quantity is null then 0
		else 1
		end as trade_quantity_validity
	, case
		when ft.trade_notional_usd < 0
			or ft.trade_notional_usd is null then 0
		else 1
		end as trade_notional_usd_validity
	, case
		when ft.trade_status not in ('FILLED', 'FAILED')
			or ft.trade_status is null then 0
		else 1
		end as trade_status_validity
	, case
		when ft.trade_created_utc_datetime < date'2020-04-01'::timestamp -- FEATURE RELEASE DATE
			or ft.trade_created_utc_datetime > now()::timestamp
			or ft.trade_created_utc_datetime is null then 0
		else 1
		end as trade_created_utc_datetime_validity
	, trade_id_validity
		*user_id_validity
		*token_id_validity
		*trade_side_validity
		*trade_price_usd_validity
		*trade_quantity_validity
		*trade_notional_usd_validity
		*trade_status_validity
		*trade_created_utc_datetime_validity as is_valid
from core.fact_trades ft
left join core.dim_users du on ft.user_id = du.user_id
left join core.dim_tokens dt on ft.token_id = dt.token_id
where is_valid = 0