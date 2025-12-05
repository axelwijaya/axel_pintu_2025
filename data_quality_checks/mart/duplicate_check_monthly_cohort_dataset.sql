select user_id
	, cohort_month
	, count(*) as count_row
from mart.monthly_cohort_dataset
group by 1,2
having count_row > 1