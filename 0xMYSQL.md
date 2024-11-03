---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# Notes on 0x MySQL literals

_TODO 2024_

I write this article as a reminder to myself since I found that I'm making the same mistake second time.

In the project I'm currently working on, we use entity IDs represented by `BIGINT UNSIGNED` in the DB ([link](https://dev.mysql.com/doc/refman/8.4/en/integer-types.html)).

For external representation the IDs are rendered to hex. Example:

| ID (decimal)          | ID (hex)           |
|-----------------------|--------------------|
| `1224980829049300745` | `11000192E425A709` |

Often we need to conduct some bug investigation which is reported for the particular ID(s). For this we may need to come up with an SQL query.

Imagine we have a table:
```sql
CREATE TABLE Transactions (
    id NOT NULL BIGINT UNSIGNED PRIMARY KEY
)
```

Apparently you can use both forms in your SQL queries:

```sql
SELECT * FROM Transactions WHERE id = 0x11000192E425A709
-- ↑ gives the same result as ↓
SELECT * FROM Transactions WHERE id = 1224980829049300745
```

(of course, the `IN` query also works)
```sql
SELECT * FROM Transactions WHERE id IN (0x11000192E425A709, ...)
```

It's worth noting that MySQL has an easy way to come from one form to the other:

```sql
SELECT HEX(1224980829049300745); -- 11000192E425A709
SELECT 0+0x11000192E425A709;     -- 1224980829049300745
```

## The problem

Now imagine, we need to look up by a list of IDs.

We can do using `IN` query mentioned above:

```sql
SELECT *
FROM Transactions
WHERE id IN (0x11000192E425A709,
             0x11000192E425A70A,
             0x11000192E425A70B)
```

So far so good.

For better flexibility I decided to use [common table expression (CTE)](https://dev.mysql.com/doc/refman/8.4/en/with.html) feature for my query:

```sql
WITH IdList AS (
              SELECT 0x11000192E425A709 id
    UNION ALL SELECT 0x11000192E425A70A
    UNION ALL SELECT 0x11000192E425A70B
)
SELECT * FROM Transactions t JOIN IdList i ON t.id = i.id;
```
      
This is where it broke. The query produced an empty result set, which at that time sent my investigation down the wrong path. The correct query should have produced non-empty result.
      
Now to easily reproduce the problem we can use this query

```sql
WITH Transactions AS ( -- real data table
    SELECT 1224980829049300745 AS id
), IdList AS ( -- search data set
    SELECT 0 AS id -- just mark the column
    UNION ALL SELECT 0x11000192E425A709 -- match
    UNION ALL SELECT 0x11000192E425A70A
    UNION ALL SELECT 0x11000192E425A70B
)
SELECT * FROM Transactions t JOIN IdList i ON t.id = i.id;
```

Surprisingly, it gives `0` rows.

If we look closer at the log, we'll see:
```
[22007][1292] Truncated incorrect DOUBLE value: ''
[22007][1292] Truncated incorrect DOUBLE value: ''
[22007][1292] Truncated incorrect DOUBLE value: ''
0 rows retrieved in 53 ms (execution: 23 ms, fetching: 30 ms)
```
