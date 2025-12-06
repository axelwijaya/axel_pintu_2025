# PINTU Assessment — Report/Dashboarding Plan

## 1. Trading concentration risk

### 1a. Is the platform overly dependent on a few tokens?

Objective:
Show the proportion of transactions (trades & P2P transfers) per token over time so stakeholders can assess platform dependency on specific tokens.

Data models:
`data_models/mart/monthly_event_count_per_token.sql`

Definitions:
- Transaction: successful trades or P2P transfers
- Token ID: Identifier for token used in the transaction
    - Source: `token_id`
- Month: Month where transaction is created
    - Source: `event_utc_month`
- Transaction Count: Number of transaction made using a specific token in the month
    - Source: `event_count`
- Total Transaction Count: Total number of transaction made in the month
    - Source: `event_count` (summed per month)
- % Share: `Transaction Count` / `Total Transaction Count`

Dashboard layout:
- Proportional stacked bar chart
    - X-axis: Month
    - Y-axis: Transaction count (stacked to 100%, show percentage)
    - Legend: Token ID
    - Tooltip:
        - Transaction Count
        - Total Transaction Count
- Line chart (optional)
    - X-axis: Month
    - Y-axis: Top-3 token's combined % Share
- Filters: date range


### 1b. Are trading volumes genuinely growing or just inflated by a small set of traders?

Objective:
Split users into 5 groups, based on the month-to-month growth of their trading volumes. Visualize how each group contributes to the total month-to-month growth using waterfall chart.

Data models:
`data_models/mart/monthly_trade_volume_growth_decomposition.sql`

Definitions:
- Month: Month where trade is created
    - Source: `trade_month`
- Trade Volume: Sum of trade amount converted to USD, regardless of trade side (buy/sell)
- User Group: Users split into 5 groups (quintiles) each month based on trade volume growth (group 1 contains lowest growth users, group 5 contains highest growth users)
    - Source: `ntile_group`
- Trade Volume Growth: Month-to-month growth of trade volume
    - Source: `trade_volume_growth`
- User Count: Number of users in user group
    - Source: `user_count`

Dashboard layout:
- Waterfall chart
    - X-axis: Month → User Group
    - Y-axis: Trade Volume Growth
    - Tooltip:
        - % Group's Trade Volume Growth share per month
        - User Count
- Filters: date range

---

## 2. User retention & cross-product usage

### 2a. Do users who start with P2P transfers eventually trade, or churn?

Objective:
Understand the behavior of users who start with P2P transfers, specifically:
- How many of them eventually perform a trade
- How long it takes for them to convert
- How many become inactive (churn)

Data models:
`data_models/mart/monthly_p2p_convert_to_trade_rate.sql`

Definitions:
- Cohort Group: Grouping of users based on the month of their first P2P transfer
    - Source: `first_p2p_transfer_month`
- Cohort Size: Number of users in the cohort group
    - Source: `user_count`
- D7 Adoption Rate: Proportion of users in the cohort group that did their first trade 0-7 days after their first P2P transfer
    - Source: `convert_d7_rate`
- D30 Adoption Rate: Proportion of users in the cohort group that did their first trade 8-30 days after their first P2P transfer
    - Source: `convert_d30_rate`
- D90 Adoption Rate: Proportion of users in the cohort group that did their first trade 31-90 days after their first P2P transfer
    - Source: `convert_d90_rate`
- D90+ Adoption Rate: Proportion of users in the cohort group that did their first trade later than 90 days after their first P2P transfer
    - Source: `convert_after_d90_rate`
- D90+ P2P-only Rate: Proportion of non-churned users in the cohort group that haven't done any trade even after 90 days since their first P2P transfer
    - Source: `not_convert_after_d90_rate`
- Churn Rate: Proportion of users in the cohort group that haven't done any transactions (trade or P2P transfers) for 90 days (calculated from current date)
    - Source: `churn_rate`

Dashboard layout:
- Table
    - Columns:
        - Cohort Group
        - Cohort Size
        - D7 Adoption Rate
        - D30 Adoption Rate
        - D90 Adoption Rate
        - D90+ Adoption Rate
        - D90+ P2P-only Rate
        - Churn Rate
- Bar Chart (optional)
    - X-axis: Cohort Group
    - Y-axis: Adoption Rate (any)
    - Tooltip:
        - Cohort Size
- Filter: Cohort Group

### 2b. How does retention differ by region and token category?

#### (i) Region retention comparison
Objective:
Provide a cohort heatmap, filterable by region, to enable comparison of user retention behavior between regions.

Data models:
`data_models/mart/monthly_cohort_dataset.sql`

Definitions:
- Cohort Group: Grouping of users based on the month of their first transaction (trade / P2P transfer)
    - Source: `cohort_group`
- Cohort Month: Months since their first transaction
    - Source: `cohort_month`
- Cohort Size: Number of users in the cohort group
    - Source: `COUNT(user_id)` per cohort group
- Transacting User Count: Number of users in the cohort group that did a transaction in said cohort month
    - Source: `COUNT(user_id)` per cohort group per cohort month
- Retention Rate: Transacting User Count / Cohort Size
- Region: Registered region of the user
    - Source: `user_region`

Dashboard layout:
- Cohort heatmap (months x months retention)
    - Columns: Cohort month
    - Rows: Cohort Group
    - Value: Retention Rate
- Filter:
    - Region
    - First Transaction Category (optional, source: `user_first_transaction_category`)
    - First Transaction Token ID (optional, source: `user_first_transaction_token_id`)

#### (ii) Token Category retention comparison
Objective:
Measure how many users return to transact in the next month (M+1 retention) for each token category.

Data models:
`data_models/mart/monthly_m1_token_category_retention_rate.sql`

Definitions:
- Month: Reference month for user transaction
    - Source: `month`
- Token Category: Category of the token used in the transaction
    - Source: `token_category`
- Current Month User Count: Number of users that transacted using tokens from said category in the referenced Month
    - Source: `current_month_user_count`
- M+1 Token Category Retention Rate: Out of Current Month User Count, how many users transacted using the same token category again in the next month
    - Source: `m1_token_retention_rate`

Dashboard layout:
- Line chart:
    - X-axis: Month
    - Y-axis: M+1 Token Category Retention Rate
    - Legend: Token Category
    - Tooltip: Current Month User Count
- Filters: date range

---

## 3. Data reliability & compliance

Please refer to the data governance doc: `docs\data_governance.md`

Inside the documentation, you can find:
- Rules for Data Quality Assurance
- Data Quality Check procedures

Data quality check scripts can be found in folder: `data_quality_checks/`