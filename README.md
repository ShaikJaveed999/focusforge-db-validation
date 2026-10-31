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
└── screenshots/
    ├── screenshot_1_not_null.png
    ├── screenshot_2_unique.png
    ├── screenshot_3_check.png
    └── screenshot_4_foreign_key.png
```

`schema/sample_data.sql` and `schema/invalid_data.sql` are the original starter files, kept unchanged. The official starter directory did not include `constraints_test.sql`; the added file contains psql test instructions and expected SQLSTATEs as SQL comments. The original test statements remain in `schema/invalid_data.sql`.

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

After loading the schema and valid sample data, run each of the four `INSERT` statements from `schema/invalid_data.sql` separately in the psql terminal so each error is visible and independently verifiable. `schema/constraints_test.sql` documents the test workflow and expected SQLSTATEs using comments only.

The four original invalid statements were manually executed in the psql terminal. Their actual PostgreSQL errors are shown in the screenshot evidence below.

## Expected PostgreSQL Errors

The four manually executed tests produced the PostgreSQL errors shown in the screenshots:

| Test | PostgreSQL error | SQLSTATE |
|---|---|---:|
| NULL task title | NOT NULL violation | `23502` |
| Duplicate `alice@email.com` | UNIQUE violation | `23505` |
| Priority `10` | CHECK violation | `23514` |
| Non-existent project ID `999` | FOREIGN KEY violation | `23503` |

The SQLSTATE values in the table identify the corresponding PostgreSQL constraint violation classes; the screenshots show the actual terminal error text. The valid sample-data inserts were not independently verified in this environment. A local PostgreSQL 18.4 service was detected, but CLI authentication was unavailable; the invalid test cases were manually executed in psql.

## Screenshot Evidence

These genuine psql terminal captures show each invalid statement and its actual PostgreSQL error:

- [NOT NULL violation — SQLSTATE `23502`](./screenshots/screenshot_1_not_null.png)
- [UNIQUE violation — SQLSTATE `23505`](./screenshots/screenshot_2_unique.png)
- [CHECK violation — SQLSTATE `23514`](./screenshots/screenshot_3_check.png)
- [FOREIGN KEY violation — SQLSTATE `23503`](./screenshots/screenshot_4_foreign_key.png)

## Test Status

- Schema changes: present in `schema/schema.sql`.
- Original sample and invalid SQL: preserved.
- Four invalid constraint tests: manually executed in psql; errors are shown in the screenshots.
- Valid sample data verification: not independently run.
- Four genuine psql screenshots: present in `screenshots/`.
