--truncate core.dim_tokens;
--insert into core.dim_tokens
select st.token_id
	, st.token_name
	, st.token_category
	, st.updated_utc_datetime
from staging.stg_tokens st