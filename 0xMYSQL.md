---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# Notes on 0x MySQL literals

_TODO 2024_

I write this article as a reminder to myself since I found that I'm making the same mistake second time.

In a project I currently work on we use entity IDs of Java type `long` (stored as `BIGINT UNSIGNED` in the DB).

For external representation the IDs are rendered to hex. Example:

| ID (decimal)          | ID (hex)           |
|-----------------------|--------------------|
| `1224980829049300745` | `11000192E425A709` |

Often we need to conduct some bug investigation which is reported for the particular ID(s). For this we may need to come up with an SQL query.

It's worth noting that MySQL has an easy way to come from one form to the other:

```sql
SELECT HEX(1224980829049300745); -- -> 11000192E425A709
SELECT 0+0x11000192E425A709;     -- -> 1224980829049300745
```
                                                           
