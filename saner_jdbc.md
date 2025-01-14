---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# One method for easier JDBC

_January 2025_
  
When you work with database in Java using [JDBC](https://en.wikipedia.org/wiki/Java_Database_Connectivity) you often encounter the code like this:

```java
    try (PreparedStatement statement =
        connection.prepareStatement(
            "SELECT * "
                + "FROM employee "
                + "WHERE (first_name LIKE ? " // 1
                + "    OR last_name LIKE ?) " // 2
                + "  AND department = ? "     // 3
                + "  AND position = ? "       // 4
                + "  AND seniority IN (?, ?) "// 5, 6
                + "  AND speciality = ? "     // 7
                + "  AND salary BETWEEN ? AND ? " // 8, 9
                + "  AND hire_date >= DATE_SUB(NOW(), INTERVAL ? YEAR) " // 10
                + "LIMIT ? OFFSET ?" // 11, 12
        )) {

      statement.setString(1, name);
      statement.setString(2, name);
      statement.setString(3, department);
      statement.setString(4, title);
      statement.setString(5, Seniority.MIDDLE);
      statement.setString(6, Seniority.SENIOR);
      statement.setString(7, speciality);
      statement.setDouble(8, salaryFrom);
      statement.setDouble(9, salaryTo);
      statement.setInt(10, yearsInCompany);
      statement.setInt(11, pageSize);
      statement.setInt(12, pageSize * (pageNo-1));

      try (ResultSet results = statement.executeQuery()) {
        while (results.next()) {
          // processing records
        }
      }
```

This is a good example. Often it's just:

```java
    try (PreparedStatement statement =
    connection.prepareStatement(
        "SELECT * FROM employee WHERE (first_name LIKE ? OR last_name LIKE ?) AND department = ? AND position = ? AND seniority IN (?, ?) AND speciality = ? AND salary BETWEEN ? AND ? AND hire_date >= DATE_SUB(NOW(), INTERVAL ? YEAR) LIMIT ? OFFSET ?")) {

      statement.setString(1, name);
      statement.setString(2, name);
      statement.setString(3, department);
      statement.setString(4, title);
      statement.setString(5, Seniority.MIDDLE);
      statement.setString(6, Seniority.SENIOR);
      statement.setString(7, speciality);
      statement.setDouble(8, salaryFrom);
      statement.setDouble(9, salaryTo);
      statement.setInt(10, yearsInCompany);
      statement.setInt(11, pageSize);
      statement.setInt(12, pageSize * (pageNo - 1));
    
      // ...
    }
```

☝ Happy matching numbers with parameter placeholders (`?`).

Wouldn't it be nice if there were a method to use the SQL arguments inline in the SQL query still avoiding SQL injections?
                                                                                                                   
Well, there is such method!

What you need is this simple helper class:

```java
public class SqlArgs {
  private final List<Object> args = new ArrayList<>();

  public String arg(Object v) {
    args.add(v);
    return "?";
  }

  public String list(Object... vv) {
    if (vv.length == 0) {
      // because `IN ()` gives a syntax error in SQL
      throw new IllegalArgumentException();
    }
    Collections.addAll(args, vv);
    return "(" + ",?".repeat(vv.length).substring(1) + ")";
  }

  public void setArgs(PreparedStatement statement) throws SQLException {
    int idx = 0;
    for (Object arg : args) {
      statement.setObject(++idx, arg);
    }
  }
}
```

And now voilà:

```java
    SqlArgs $ = new SqlArgs();

    try (PreparedStatement statement =
        connection.prepareStatement(
            "SELECT * "
                + "FROM employee "
                + "WHERE (first_name LIKE " + $.arg(name)
                + "    OR last_name LIKE " + $.arg(name) + ") "
                + "  AND department = " + $.arg(department)
                + "  AND position = " + $.arg(title)
                + "  AND seniority IN " + $.list(Seniority.MIDDLE, Seniority.SENIOR)
                + "  AND speciality = " + $.arg(speciality)
                + "  AND salary BETWEEN " + $.arg(salaryFrom) + " AND " + $.arg(salaryTo)
                + "  AND hire_date >= DATE_SUB(NOW(), INTERVAL " + $.arg(yearsInCompany) + " YEAR) "
                + "LIMIT " + $.arg(pageSize) + " OFFSET " + $.arg(pageSize * (pageNo-1))
        )) {

      $.setArgs(statement); // just one line instead of tedious statement.set*() calls!

      // processing records
    }
```

How cool is that? 😀

But you have more! It's as easy with this approach to construct dynamic SQL:

```java
    connection.prepareStatement(
        "SELECT * "
            + "FROM employee "
            + "WHERE 1=1 "
            + (name       != null ? " AND (first_name LIKE " + $.arg(name) + " OR last_name LIKE " + $.arg(name) + ") " : "")
            + (department != null ? " AND department = " + $.arg(department) : "")
            + (title      != null ? " AND position = " + $.arg(title) : "")
            + (seniority  != null ? " AND seniority IN " + $.list(seniority) : "")
            + (speciality != null ? " AND speciality = " + $.arg(speciality) : "")
            + (salaryFrom > 0     ? " AND salary >= " + $.arg(salaryFrom) : "")
            + (salaryTo   > 0     ? " AND salary <= " + $.arg(salaryTo) : "")
            + (yearsInCompany > 0 ? " AND hire_date >= DATE_SUB(NOW(), INTERVAL " + $.arg(yearsInCompany) + " YEAR) " : "")
            + "LIMIT " + $.arg(pageSize) + " OFFSET " + $.arg(pageSize * (pageNo-1))
      )
```