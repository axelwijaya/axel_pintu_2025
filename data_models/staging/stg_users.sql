--truncate staging.stg_users;
--insert into staging.stg_users
select ru.user_id		::varchar	as user_id
	, ru.region			::varchar	as user_region
	, ru.signup_date	::date		as user_signup_date
	, ru.signup_date	::timestamp	as updated_utc_datetime
from raw_kyc.raw_users ru
where 1=1
qualify row_number() over (partition by ru.user_id order by ru.signup_date desc) = 1