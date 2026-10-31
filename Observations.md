# FocusForge Database Validation Observations

## 1. Original Schema Problems

The original `schema/schema.sql` declared primary keys but lacked the requested integrity rules:

- `users.name` and `users.email` could be `NULL`, and duplicate email addresses were allowed.
- `projects.project_name` could be `NULL`.
- `tasks.title` could be `NULL`.
- `tasks.priority` accepted values outside 1 through 5.
- `tasks.project_id` could refer to a project that did not exist.

The four original invalid inserts remain unchanged in `schema/invalid_data.sql`, as does the valid sample script in `schema/sample_data.sql`. The official starter did not contain `constraints_test.sql`; the added file contains explanatory pgAdmin comments and expected SQLSTATEs, not psql commands.

## 2. Missing Data Integrity Rules

The schema needed `NOT NULL` on user names and emails, project names, and task titles; `UNIQUE` on user email; a range `CHECK` on task priority; and a foreign key from `tasks.project_id` to `projects.id`.

## 3. NOT NULL Constraint

`users.name`, `users.email`, `projects.project_name`, and `tasks.title` are `NOT NULL`, so required identifying values cannot be omitted. The null-title insert was manually run in pgAdmin and PostgreSQL rejected it with SQLSTATE `23502`.

## 4. UNIQUE Constraint

`users.email` is both `NOT NULL` and `UNIQUE`. This prevents multiple user records from sharing an email address. The duplicate-email insert was manually run in pgAdmin and rejected with SQLSTATE `23505`.

## 5. CHECK Constraint

`tasks.priority` has `CHECK (priority BETWEEN 1 AND 5)`, keeping numeric priorities in the permitted range. The priority-10 insert was manually run in pgAdmin and rejected with SQLSTATE `23514`.

## 6. FOREIGN KEY Constraint

`tasks.project_id` references `projects(id)`, preventing a task from referring to a missing project. The project-ID-999 insert was manually run in pgAdmin and rejected with SQLSTATE `23503`.

## 7. Valid Sample Data Test Results

**Not independently verified in this environment.** PostgreSQL 18.4 is installed and its Windows service is running, but connecting as `postgres` over localhost failed because no password was available (`fe_sendauth: no password supplied`). Run the original sample script against a clean database after configuring PostgreSQL access:

```powershell
psql -d focusforge_validation -f schema/sample_data.sql
```

## 8. Invalid Data Test Results

The four original invalid inserts were manually executed in pgAdmin. The genuine screenshots in `screenshots/` show each statement and PostgreSQL's corresponding error:

| Starter test case | Observed constraint failure | Observed SQLSTATE | Evidence |
|---|---|---:|---|
| Task with `title = NULL` | NOT NULL | `23502` | [screenshot_1_not_null.png](./screenshots/screenshot_1_not_null.png) |
| User with `alice@email.com` repeated | UNIQUE | `23505` | [screenshot_2_unique.png](./screenshots/screenshot_2_unique.png) |
| Task with priority `10` | CHECK | `23514` | [screenshot_3_check.png](./screenshots/screenshot_3_check.png) |
| Task with `project_id = 999` | FOREIGN KEY | `23503` | [screenshot_4_foreign_key.png](./screenshots/screenshot_4_foreign_key.png) |

`schema/constraints_test.sql` explains how to execute the cases individually in pgAdmin. The actual original SQL statements remain in `schema/invalid_data.sql`.

## 9. What the Database Now Rejects

PostgreSQL rejected a task with a `NULL` title, a duplicate user email, a priority outside 1–5, and a task referencing a nonexistent project, as documented above. The schema also rejects null user names, null user emails, and null project names through their `NOT NULL` definitions.

## 10. What the Database Still Accepts

Only the requested constraints were added. The schema still permits empty strings in required text columns, does not validate email format, allows `NULL` in `tasks.priority` and `tasks.project_id`, and imposes no priority rules beyond the specified range. A foreign key does not itself make its referencing column non-null.

## 11. Conclusion

The schema enforces the requested rules while preserving the original table names, columns, data types, valid sample inserts, and invalid test cases. The four invalid test outcomes are supported by genuine pgAdmin screenshots. The valid sample data has not been independently verified in this environment.
