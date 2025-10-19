---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# Generate SQL in SQL with DuckDB

_October 2025_

Here is an SQL query I came up with to produce SQL using [DuckDB](https://duckdb.org/).

```sql
.mode column
.headers off
select
    IF(ROW_NUMBER() OVER () > 1, e'union all\n', '') ||
    'select hex(tr_id), tr_scheme_transaction_id, tr_scheme_settlement_date from transactions'
        || ' where tr_date between ''' || DATE_ADD("Date (Transaction Date)",-1) || ''' and ''' || DATE_ADD("Date (Transaction Date)",1) || ''''
        || ' and tr_amount=' || "Transaction Amount"
        || ' and tr_pay_num_l4=''' || RIGHT(TRIM("Card Number"),4) || ''''
        || ' and tr_scheme_transaction_id like ''___' || "Banknet Reference Number" || ''''

from read_csv("/path/to/chargebacks.csv")
```

Now, running it with `duckdb < 1.sql` produces an output similar to:

```sql
select hex(tr_id), tr_scheme_transaction_id, tr_scheme_settlement_date from transactions where tr_date between '2025-XX-XX' and '2025-XX-XX' and tr_amount=XX.95 and tr_pay_num_l4='XXXX' and tr_scheme_transaction_id like '___XXXXXX'                                                                                                      
union all
select hex(tr_id), tr_scheme_transaction_id, tr_scheme_settlement_date from transactions where tr_date between '2025-XX-XX' and '2025-XX-XX' and tr_amount=XX.95 and tr_pay_num_l4='XXXX' and tr_scheme_transaction_id like '___XXXXXX'                                                                                              
union all
select hex(tr_id), tr_scheme_transaction_id, tr_scheme_settlement_date from transactions where tr_date between '2025-XX-XX' and '2025-XX-XX' and tr_amount=XX.95 and tr_pay_num_l4='XXXX' and tr_scheme_transaction_id like '___XXXXXX'
...
```
(all potentially sensitive data is obfuscated with `X`)

Why may this be even needed? In this case I needed to confirm the chargebacks matching logic against real data before committing to actual implementation. Simply speaking, I wanted to make sure the data coming via the `chargebacks.csv` file can correctly match to the transaction records in the database.

I used to use a scripting language like Python to do this before I discovered DuckDB. I found this SQL-in-SQL approach much more elegant and straightforward. DuckDB allows directly querying CSV files. With a script it needed a separate CSV parsing step which added friction. 

Couple things to note regarding the query above:

1. `.mode column` is needed to hint DuckDB to not apply any quoting to the output, thus preserving the resulting SQL intact.
2. `.headers off` - we want to get the clean SQL, we don't want DuckDB to add default headers.
3. The trick using `IF` and `ROW_NUMBER() OVER ()` ([link](https://duckdb.org/docs/stable/sql/functions/window_functions)) is needed to only insert `union all` after the first `select`.
4. The `e` modifier in `e'union all\n'` is needed to output the actual newline instead of `\n`. 
5. You can reference columns in the CSV file by their actual names (like `"Banknet Reference Number"`), not necessarily their position.
6. `read_csv()` - the function you use to query CSV files ([link](https://duckdb.org/docs/stable/data/csv/overview)). Automatic CSV parsing is applied, which seems to work in most cases. If it doesn't, you can supply many available options to the function.

I think DuckDB is becoming an inevitable addition to my development toolbox.




 
                                   


