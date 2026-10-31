# FocusForge Database Validation Observations

## 1. Original Schema Problems

The original `schema/schema.sql` declared primary keys, but did not enforce the required rules for the other columns. As a result:

- `users.name` and `users.email` could be `NULL`, and the same email could be stored for multiple users.
- `projects.project_name` could be `NULL`.
- `tasks.title` could be `NULL`.
- `tasks.priority` accepted integers outside the required range of 1 through 5.
- `tasks.project_id` could refer to a project ID that did not exist.

The starter's four invalid inserts are preserved unchanged in `schema/invalid_data.sql`. The original `schema/sample_data.sql` is also preserved unchanged. The official assignment folder did not contain a `constraints_test.sql`; a psql runner has been added to execute the original invalid inserts.

## 2. Missing Data Integrity Rules

The schema needed `NOT NULL` rules for required names, email addresses, project names, and task titles; a `UNIQUE` rule for user email; a range `CHECK` for task priority; and a `FOREIGN KEY` from `tasks.project_id` to `projects.id`.

## 3. NOT NULL Constraint

`users.name`, `users.email`, `projects.project_name`, and `tasks.title` are now `NOT NULL`. This prevents records from omitting values needed to identify users, projects, and tasks. In particular, the starter's null-title task should fail with SQLSTATE `23502`.

## 4. UNIQUE Constraint

`users.email` is now `UNIQUE` as well as `NOT NULL`. This prevents two user rows from having the same email address. The starter duplicate-email insert should fail with SQLSTATE `23505`.

## 5. CHECK Constraint

`tasks.priority` now has `CHECK (priority BETWEEN 1 AND 5)`. This keeps numeric priorities inside the specified range. The starter priority-10 insert should fail with SQLSTATE `23514`.

## 6. FOREIGN KEY Constraint

`tasks.project_id` now references `projects(id)`. This prevents a task from referring to a project row that does not exist. The starter project-ID-999 insert should fail with SQLSTATE `23503`.

## 7. Valid Sample Data Test Results

**Not run in this environment.** PostgreSQL 18.4 is installed and its Windows service is running, but connecting as `postgres` over localhost failed because no password was available (`fe_sendauth: no password supplied`). Therefore the original sample inserts have not been verified against the constrained schema here. To run the check after configuring access:

```powershell
psql -d focusforge_validation -f schema/sample_data.sql
```

## 8. Invalid Data Test Results

**Not run in this environment.** The expected SQLSTATE codes below describe PostgreSQL's corresponding constraint-violation classes; they are not claimed as observed test output. Re-run the actual starter test cases with:

```powershell
psql -d focusforge_validation -f schema/constraints_test.sql
```

Expected outcomes, pending execution:

| Starter test case | Expected constraint failure | Expected SQLSTATE | Result here |
|---|---|---:|---|
| Task with `title = NULL` | NOT NULL | `23502` | Not run |
| User with `alice@email.com` repeated | UNIQUE | `23505` | Not run |
| Task with priority `10` | CHECK | `23514` | Not run |
| Task with `project_id = 999` | FOREIGN KEY | `23503` | Not run |

The test runner executes the unchanged inserts as separate autocommit statements and continues after each error, so one rejected insert does not prevent later tests from running.

## 9. What the Database Now Rejects

Based on the DDL, PostgreSQL should reject `NULL` values for the four required text columns, duplicate non-NULL user email addresses, task priorities below 1 or above 5, and task references to non-existent non-NULL project IDs. These behaviors remain pending live database verification in this environment.

## 10. What the Database Still Accepts

Only the requested constraints were added. Consequently, the schema still permits empty strings in required text columns, does not validate email format, allows `NULL` for `tasks.priority` and `tasks.project_id`, and does not impose rules beyond the specified priority range. A foreign key does not itself make its referencing column non-null.

## 11. Conclusion

The schema now expresses the requested data integrity rules at the database level while preserving the original table names, columns, data types, valid sample inserts, and invalid test cases. PostgreSQL authentication prevented execution of the valid/invalid SQL tests and genuine terminal screenshots during this run; those items must be completed after database access is configured.
