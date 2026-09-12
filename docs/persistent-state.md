# Persistent dashboard state

The dashboard stores learning progress, external AI model configurations (including API
tokens), and the selected model in SQLite. Docker Compose mounts `./data/dashboard/`
at `/var/opt/app/data/`; the database is `db.sqlite3` inside that directory. Container
recreation and image rebuilds do not remove it. Keep the whole directory, not just a
mounted database file, so SQLite can create its journal files alongside it.

Progress belongs to one local user, not a browser cookie. Another browser on the
same SCL installation sees the same solves.

Ollama model files live separately in `./ollama/`, even when the optional container
is stopped. See [AI assistant](./ai-assistant.md) for startup and removal instructions.
Chat history, browser preferences, and changes inside Hackerlab are outside this
persistence feature.

## Resetting state

Use **Reset state** in the top bar, select a scope, and confirm:

- **Learning progress:** clear solved tasks, including campaign progress.
- **AI settings:** remove external configurations and tokens, and clear model selection.
- **Everything:** clear both of the above.

The reset updates SQLite in a transaction; it does not delete a live database.
Running labs, downloaded models, chat history, browser preferences, and Hackerlab
files are not touched.

Migration backups are retained, so a reset is not a secure erasure of old credentials.
The database and backups contain unencrypted API tokens: protect the data directory
and do not share or commit it. New database and backup files use owner-only permissions
where the host filesystem supports them. They are excluded from Git and Docker build
contexts, and are not served by the dashboard.

## Upgrades and recovery

On startup, the dashboard applies missing schema migrations and then refreshes
repository metadata (classes, challenges, campaigns, pages, tasks, and plugins).
This refresh is atomic and preserves progress and AI settings. Removed content is
hidden; its solves are retained in case the same challenge/task IDs return. Keep IDs
stable when editing content, and assign new IDs to genuinely different tasks.

Before upgrading an existing database, a consistent SQLite backup is created in
`data/dashboard/backups/`. Missing migrations run in one transaction. A failure rolls
back the upgrade and prevents startup; fix the issue and restart. An application
older than the database schema refuses to start instead of modifying the schema.
Backups are not created on every restart and are not automatically deleted.

To restore a backup, stop the dashboard first. Preserve the current data directory,
then place the chosen backup at `data/dashboard/db.sqlite3` in a clean directory
without old SQLite journal/WAL files. Use an application version compatible with
that backup, then restart. Do not copy a live database with ordinary file-copy tools;
use SQLite's backup API, or stop the dashboard before copying the whole directory.

## Adding a schema migration

`dashboard/server/migrations.py` contains an ordered `MIGRATIONS` tuple. SQLite's
`PRAGMA user_version` records how many have completed. Append a new function for each
schema change; do not reorder or change released migrations (including their schema
helpers). Do not commit, close the connection, or use `executescript` in a migration:
the runner owns the transaction. Preserve user data explicitly when rebuilding tables.

Test fresh initialization, an upgrade from every supported older schema, repeated
startup, rollback after a failed migration, and refusal of a newer database. Backend
checks use temporary databases and do not require starting any lab containers:

```bash
python -m unittest discover -s tests -p 'test_persistence.py'
```
