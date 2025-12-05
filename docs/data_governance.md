# Data Governance

This document outlines how data quality, integrity, lineage, and trust are enforced in this analytics repository.

---

## 1. Purpose
The goal of this document is to ensure that:
- Data is **accurate**, **consistent**, and **trustworthy**
- Business logic is **transparent** and **reproducible**
- Teams consuming CORE tables have confidence in the data
- Data quality checks and deduplication are explicitly defined
- Table lineage and ownership are clear

---

## 2. Data Architecture

Data flows through four logical layers:

```

RAW → STAGING → CORE → MART

````

**Layer descriptions:**

- **RAW:** Extracted from source systems; may contain duplicates and all datatypes are STRING
- **STAGING:** Type casting and deduplication
- **CORE:** Dimensions and facts, business logic (e.g., trade notional), conformed keys
- **MART:** Subject-area models optimized for dashboards and ad-hoc analytics  

---

## 3. Table Ownership

| Layer  | Ownership                      |
|--------|--------------------------------|
| RAW    | Data Engineers                 |
| STAGING| Data Engineers                 |
| CORE   | Data Analysts                  |
| MART   | Data Analysts                  |

---

## 4. Data Quality Assurance Rules

### **Layered Architecture**
- **STAGING** tables can only query from **RAW** layer
- **CORE** tables can only query from **STAGING** layer
- **MART** tables can only query from **CORE** layer & other **MART** tables if necessary

### **Uniqueness Constraints**
- Every table must have defined PRIMARY KEY(s)  
- Deduplication is only applied on STAGING layer, with logic:  
```sql
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY <primary_key>
    ORDER BY <created_time> DESC
) = 1
````

### **Type Casting**
- Amounts → `numeric(38,9)`  or `numeric(38,18)`, `float`s are only allowed on MART layer
- Counts → `int`
- Timestamps → `timestamp without timezone` convert to UTC, non-UTC timestamps are only allowed on MART layer
- Dates → `date`
- IDs → `varchar`

### **Data Insertion**
- Truncate insert is only allowed for these tables:
    - small dimension tables with no update timestamps
    - MART tables with rolling metrics (e.g. `monthly_p2p_convert_to_trade_rate`)
- Other than the tables mentioned in first bullet point, all tables should either use delete insert, or incremental insert (depends on the nature of the data)
- Other than the tables mentioned in first bullet point, all tables should provide an `updated_utc_datetime` column which will be used for delete/incremental insert, with these constraints:
    - Not NULL
    - Reflects the actual datetime of the latest change that could occur to any of the values in the row (typically using `MAX` for aggregated rows, and `GREATEST()` for rows from a joined table)

### **Relations**
- All foreign keys in fact tables must reference **existing** primary key in a dimension table
- Prioritize joining tables using foreign keys and the referenced primary keys

---

## 5. Data Quality Control Procedures
Multiple quality checks and monitoring logics are set in this folder:
 `\axel_pintu_2025\data_quality_checks\`

 The results of these logics should then be utilized as a trigger condition for alerts.

 Below are some of the checks available currently:
 - **Duplication Check**
    - Mandatory, set-up for all tables in every layer
    - Alert will be triggered when at least 1 row is returned
    - Check is done based on the defined primary keys for each tables:
```sql
SELECT <primary_key>
	, count(*) as count_row
from <table>
group by <primary_key>
having count_row > 1
````

- **Outlier Check**
    - Not mandatory, set-up based on request
    - Currently available logic is based on percentiles (P99, P95, P90, MAX)
    - By default, the alert will be triggered when `MAX() > 10*P99`, this threshold can be altered based on agreement with the users.

- **Validity Check**
    - Mandatory for critical fact tables
    - Check is done per column based on the validity of the data
    - Some examples:
        - Primary keys: check if NULL
        - Foreign keys: check if exist in referenced dimension table
        - Created datetime: compare with feature release date and current datetime
        - Transacted quantity/amount: check if negative
        - Enumerated values: check if value is in set (e.g. `status in ('SUCCESS', 'FAILED')`)
    - Alert will be triggered when any of these checks is failed

Data team should also provide a ticketing system (can be JIRA Tickets or GForm) specifically for data quality issue, to let users report and monitor an issue.

---

## 6. Access Control

| Role                   | RAW | STAGING | CORE                 | MART                    | Notes                             |
| ---------------------- | --- | ------- | -------------------- | ----------------------- | --------------------------------- |
| **Data Engineer (DE)** | R/W | R/W     | R/W (with at least DA review)| R     | Full access to build pipelines, maintain transformations, query optimization, and fix issues |
| **Data Analyst (DA)**  | R   | R       | R/W (with at least peer & DE review) | R/W (ideally with peer review) | Read access for auditing; can propose updates to CORE with peer & DE approval (DE checks for query performance); critical MART updates requires with peer review |

*R: Read; W: Write

---

## 7. Naming Conventions
**Tables**
- STAGING: `stg_<source>`
- CORE:
    - Fact tables: `fact_<subject>`
    - Dimension tables: `dim_<entity>`

**Columns**
- Applied on STAGING and CORE layers
- Generally the format would be `<entity/subject>_<attribute/measure>`
- Attribute and measure names should be standardized in another document to avoid confusions
- Some additional rules:
    - Timestamp fields: `<event>_<timezone>_datetime`
    - Monetary amounts with currency need to include suffix `_<currency>`
    - Foreign keys: `<entity>_id`
    - Primary keys: `<subject>_id`

---