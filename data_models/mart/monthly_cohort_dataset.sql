with user_cohort_group as (
	select du.user_id
		, du.user_region
		, du.user_first_transaction_category 
		, du.user_first_transaction_token_id 
		, date_trunc('month', least(du.user_first_p2p_utc_datetime, du.user_first_trade_utc_datetime)) as cohort_group
		, du.updated_utc_datetime
	from core.dim_users du
	where cohort_group is not null
)
, transacting_users as (
	select date_trunc('month', fe.event_utc_datetime) as transacting_month
		, fe.user_id
		, max(fe.updated_utc_datetime) as updated_utc_datetime
	from core.fact_events fe
	where fe.event_status in ('SUCCESS', 'FILLED')
	group by 1,2
)
select uc.cohort_group
    , uc.user_id
    , uc.user_region
	, uc.user_first_transaction_category 
	, uc.user_first_transaction_token_id 
    , tr.transacting_month
    , ((extract('years' from tr.transacting_month) - extract('years' from uc.cohort_group)) * 12) + (extract('months' from tr.transacting_month) - extract('months' from uc.cohort_group)) as cohort_month
    , greatest(uc.updated_utc_datetime, tr.updated_utc_datetime) as updated_utc_datetime
from user_cohort_group uc
left join transacting_users tr
    on uc.user_id = tr.user_id