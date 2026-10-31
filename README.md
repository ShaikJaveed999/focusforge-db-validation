# FocusForge DB-Level Validation

FocusForge is a small productivity database with users, projects, and tasks. This project applies PostgreSQL constraints to enforce the assignment's required data integrity rules and retains the official sample and invalid test data.

## Assignment Objective

Enforce required user, project, and task values; prevent duplicate user emails; limit task priorities to 1 through 5; and prevent tasks from referencing projects that do not exist.

## Original Schema Problems

The starter schema allowed `NULL` user names and emails, duplicate user emails, `NULL` project names and task titles, priorities outside the required range, and task references to missing projects. The details are recorded in [Observations.md](./Observations.md).

## Constraints Implemented

| Table.column | Constraint | Purpose |
|---|---|---|
| `users.name` | `NOT NULL` | Require a user name |
| `users.email` | `NOT NULL`, `UNIQUE` | Require an email and prevent duplicate addresses |
| `projects.project_name` | `NOT NULL` | Require a project name |
| `tasks.title` | `NOT NULL` | Require a task title |
| `tasks.priority` | `CHECK (priority BETWEEN 1 AND 5)` | Keep numeric priority in the accepted range |
| `tasks.project_id` | `REFERENCES projects(id)` | Require any non-NULL project reference to identify an existing project |

No table names, column names, or data types were changed.

## Project Structure

```text
.
├── schema/
│   ├── constraints_test.sql
│   ├── invalid_data.sql
│   ├── sample_data.sql
│   └── schema.sql
├── Observations.md
├── README.md
├── screenshot_1_not_null.png       (pending genuine capture)
├── screenshot_2_unique.png         (pending genuine capture)
├── screenshot_3_check.png          (pending genuine capture)
└── screenshot_4_foreign_key.png    (pending genuine capture)
```

`schema/sample_data.sql` and `schema/invalid_data.sql` are the original starter files, kept unchanged. The official starter directory did not include `constraints_test.sql`; that file is a psql runner for the original four invalid statements.

## Database Setup

Use PostgreSQL and run commands from the project root. Create the assignment-specific database once:

```powershell
createdb focusforge_validation
```

To reset the tables in this disposable test database before re-running the scripts:

```powershell
psql -d focusforge_validation -c "DROP TABLE IF EXISTS tasks, projects, users CASCADE;"
```

Create the constrained schema, then insert the original valid sample rows:

```powershell
psql -d focusforge_validation -f schema/schema.sql
psql -d focusforge_validation -f schema/sample_data.sql
```

The valid sample statements are expected to insert two users, two projects, and two tasks. Run them in a clean database/schema; the original scripts do not use `IF NOT EXISTS`.

## How to Run Constraint Tests

Run all four original invalid inserts using the psql script:

```powershell
psql -d focusforge_validation -f schema/constraints_test.sql
```

Each statement runs in its own autocommit transaction. The runner continues after errors and requests verbose output so the PostgreSQL SQLSTATE is displayed. A nonzero-free psql exit is not proof of success: inspect each actual error and confirm its SQLSTATE.

For a single interactive test and screenshot, start psql:

```powershell
psql -d focusforge_validation
```

At the `focusforge_validation=#` prompt, set verbose error output, execute exactly one statement, and capture the statement together with PostgreSQL's real error before running the next test:

```sql
\set VERBOSITY verbose
INSERT INTO tasks (id, title, priority, project_id) VALUES (3, NULL, 3, 1);
INSERT INTO users (id, name, email) VALUES (3, 'Charlie', 'alice@email.com');
INSERT INTO tasks (id, title, priority, project_id) VALUES (4, 'Testing Task', 10, 1);
INSERT INTO tasks (id, title, priority, project_id) VALUES (5, 'Ghost Task', 2, 999);
```

The statements above are the original starter cases. Capture each one separately, not all at once, to make the required four evidence images readable.

## Expected PostgreSQL Errors

These are expected constraint classes, **not results observed in this environment**:

| Test | Expected error | SQLSTATE |
|---|---|---:|
| NULL task title | NOT NULL violation | `23502` |
| Duplicate `alice@email.com` | UNIQUE violation | `23505` |
| Priority `10` | CHECK violation | `23514` |
| Non-existent project ID `999` | FOREIGN KEY violation | `23503` |

PostgreSQL 18.4 and its Windows service were detected, but connecting as `postgres` failed because the server required a password and none was available. The valid and invalid SQL tests have therefore **not been executed** here. No test result is represented as verified.

## Screenshot Evidence

The assignment requires four genuine psql captures. No screenshots are included because the database tests could not be run and fabricated terminal output would not be valid evidence. After successfully running each interactive test, capture the real psql statement and error and save the images in this project root using these exact names:

- `screenshot_1_not_null.png` — expected SQLSTATE `23502`
- `screenshot_2_unique.png` — expected SQLSTATE `23505`
- `screenshot_3_check.png` — expected SQLSTATE `23514`
- `screenshot_4_foreign_key.png` — expected SQLSTATE `23503`

**Status: pending manual execution and genuine screenshot capture.**

## Test Status

- Schema changes: present in `schema/schema.sql`.
- Original sample and invalid SQL: preserved.
- PostgreSQL service: detected (18.4); connection requires credentials not available in this run.
- Valid sample data verification: not run.
- Four invalid constraint verifications: not run.
- Four screenshot files: pending.
