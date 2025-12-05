select fp.transfer_id
	, case
		when fp.transfer_id is null then 0
		else 1
		end as transfer_id_validity
	, case
		when dus.user_id is null then 0
		else 1
		end as sender_user_id_validity
	, case
		when dur.user_id is null then 0
		else 1
		end as receiver_user_id_validity
	, case
		when dt.token_id is null then 0
		else 1
		end as token_id_validity
	, case
		when fp.transfer_quantity < 0
			or fp.transfer_quantity is null then 0
		else 1
		end as transfer_quantity_validity
	, case
		when fp.transfer_status not in ('SUCCESS', 'FAILED')
			or fp.transfer_status is null then 0
		else 1
		end as transfer_status_validity
	, case
		when fp.transfer_created_utc_datetime < date'2020-04-01'::timestamp -- FEATURE RELEASE DATE
			or fp.transfer_created_utc_datetime > now()::timestamp
			or fp.transfer_created_utc_datetime is null then 0
		else 1
		end as transfer_created_utc_datetime_validity
	, transfer_id_validity
		*sender_user_id_validity
		*receiver_user_id_validity
		*token_id_validity
		*transfer_quantity_validity
		*transfer_status_validity
		*transfer_created_utc_datetime_validity as is_valid
from core.fact_p2p_transfers fp
left join core.dim_users dus on fp.sender_user_id = dus.user_id
left join core.dim_users dur on fp.receiver_user_id = dur.user_id
left join core.dim_tokens dt on fp.token_id = dt.token_id
where is_valid = 0