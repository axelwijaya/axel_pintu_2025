-- send alert if max > 10*p99 (multiplier can be customized based on agreement with stakeholders)
select min(trade_notional_usd) as min
	, percentile_cont(0.90) within group (order by trade_notional_usd) as p90
	, percentile_cont(0.95) within group (order by trade_notional_usd) as p95
	, percentile_cont(0.99) within group (order by trade_notional_usd) as p99
	, max(trade_notional_usd) as max
from core.fact_trades