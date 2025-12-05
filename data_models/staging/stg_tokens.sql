--truncate staging.stg_tokens;
--insert into staging.stg_tokens
select rt.token_id	::varchar	as token_id
	, rt.token_name	::varchar	as token_name
	, rt.category	::varchar	as token_category
	, now()			::timestamp as updated_utc_datetime
from raw_config.raw_tokens rt
where 1=1
qualify row_number() over (partition by rt.token_id order by rt.token_name desc) = 1