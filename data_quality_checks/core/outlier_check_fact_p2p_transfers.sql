-- send alert if max > 10*p99 (multiplier can be customized based on agreement with stakeholders)
select token_id
	, min(transfer_quantity) as min
	, percentile_cont(0.90) within group (order by transfer_quantity) as p90
	, percentile_cont(0.95) within group (order by transfer_quantity) as p95
	, percentile_cont(0.99) within group (order by transfer_quantity) as p99
	, max(transfer_quantity) as max
from core.fact_p2p_transfers
group by 1