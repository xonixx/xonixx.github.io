---
layout: post
title: 'Notes on 0x MySQL literals'
description: 'I describe some nuances of using 0x literals in MySQL'
---

# Notes on 0x MySQL literals

_November 2024_

I write this article as a reminder to myself since I found that I'm making the same mistake second time.

In the project I'm currently working on, we use entity IDs represented by `BIGINT UNSIGNED` in the DB ([link](https://dev.mysql.com/doc/refman/8.4/en/integer-types.html)).

For external representation the IDs are rendered to hex. Example:

| ID (decimal)          | ID (hex)           |
|-----------------------|--------------------|
| `1224980829049300745` | `11000192E425A709` |

Often we need to investigate a bug reported for a specific ID(s). For this we may need to come up with an SQL query.

Imagine we have a table:
```sql
CREATE TABLE Transactions (
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY
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
SELECT HEX(1224980829049300745); -- ⟶ 11000192E425A709
SELECT 0+0x11000192E425A709;     -- ⟶ 1224980829049300745
```

## The problem

Now imagine, we need to look up by a list of IDs.

We can do it using `IN` query mentioned above:

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
      
This is where it broke. The query produced an empty result set, which at the time sent my investigation down the wrong path. The correct query should have produced non-empty result.
      
Now to easily reproduce the problem we can use this query:

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

## What's going on?

As a Java developer, I was naive to think that `0xABC` is just an alternative syntax for defining a number. I was almost right, but it's slightly trickier than that. It appears, the treatment of `0x` literal depends on if it appears in numeric context, in which case it's treated as `BIGINT UNSIGNED`, otherwise it represents a binary string `VARBINARY(N)` ([link](https://dev.mysql.com/doc/refman/8.4/en/hexadecimal-literals.html)). 

So apparently, for my "clever" CTE-based query the `IdList.id` produces binary string and `Transactions.id` produces numeric, however for the `JOIN` condition, although in numeric context, the string gets cast (in fact, truncated) to numeric `0`.

Thus, you can easily reproduce the problem by a simple query:
```sql
SELECT 'a' = 7; -- ⟶ 0
```
This query generates the same warning:
```
[22007][1292] Truncated incorrect DOUBLE value: 'a'
```

Note, how it changes to 1 for comparing with `0`:
```sql
SELECT 'a' = 0; -- ⟶ 1
```

This means for my "clever" query all `id` values coming from `IdList` were treated as `0`!

Mystery solved. But how can we fix?

## The fix

The same [documentation link](https://dev.mysql.com/doc/refman/8.4/en/hexadecimal-literals.html) also gives the recipes:

- `0+0xABC`
- `CAST(0xABC AS UNSIGNED)`

Both will cast the `0x` value as `BIGINT UNSIGNED`, but I prefer the first option for brevity.

Now, the fixed query will look like:

```sql
WITH Transactions AS ( -- real data table
    SELECT 1224980829049300745 AS id
), IdList AS ( -- search data set
              SELECT 0+0x0 AS id -- just mark the column
    UNION ALL SELECT 0+0x11000192E425A709 -- match
    UNION ALL SELECT 0+0x11000192E425A70A
    UNION ALL SELECT 0+0x11000192E425A70B
)
SELECT * FROM Transactions t JOIN IdList i ON t.id = i.id;
```

## Bonus

You may ask why `SELECT 0+0x0` not just `SELECT 0`. The reason is subtle.

In the first case the the `IdList.id` will be inferred as `BIGINT UNSIGNED` (preferable), while in the second case `DECIMAL(21)`. You may wonder, why is so? Well, the type of `0` is `BIGINT` (signed). The type of `0+0x` is `BIGINT UNSIGNED`. The smallest type that fits both without loss is `DECIMAL(21)`.

More cases for comparison:

| SQL | Type |
|-----|------|
|`SELECT 0`|`BIGINT:19`|
|`SELECT 0x0`|`VARBINARY:1`|
|`SELECT --0x0`|`DOUBLE:17`|
|`SELECT CAST(0 AS UNSIGNED)`|`BIGINT UNSIGNED:20`|
|`SELECT 0+0x0`|`BIGINT UNSIGNED:20`|
|`SELECT 0x11000192E425A70B`|`VARBINARY:8`|
|`SELECT 0     UNION ALL SELECT 0+0x11000192E425A70B`|`DECIMAL:21`|
|`SELECT 0+0x0 UNION ALL SELECT 0+0x11000192E425A70B`|`BIGINT UNSIGNED:20`|

The table above was generated by this small Java program:

```java
import java.sql.*;

public class ShowType {
  public static void main(String[] args) throws Exception {
    System.out.println("| SQL | Type |");
    System.out.println("|-----|------|");
    for (String sql :
        new String[] {
          "SELECT 0",
          "SELECT 0x0",
          "SELECT --0x0",
          "SELECT CAST(0 AS UNSIGNED)",
          "SELECT 0+0x0",
          "SELECT 0x11000192E425A70B",
          "SELECT 0     UNION ALL SELECT 0+0x11000192E425A70B",
          "SELECT 0+0x0 UNION ALL SELECT 0+0x11000192E425A70B"
        }) {
      try (Connection conn = getConnection();
          Statement statement = conn.createStatement();
          ResultSet resultSet = statement.executeQuery(sql)) {
        ResultSetMetaData metaData = resultSet.getMetaData();
        System.out.println(
            "|`" + sql + "`|`" + metaData.getColumnTypeName(1) + ":" + metaData.getPrecision(1) + "`|");
      }
    }
  }

  private static Connection getConnection() throws SQLException {
    return DriverManager.getConnection("jdbc:mysql://127.0.0.1/mysql", "root", "root");
  }
}
```
