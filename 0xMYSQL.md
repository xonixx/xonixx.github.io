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
-- ↑ gives same result as ↓
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
