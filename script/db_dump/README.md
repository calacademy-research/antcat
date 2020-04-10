#### `download_latest`

Command: `./script/db_dump/download_latest`

Requires the current user to have ssh access to EngineYard.

#### `import`, `import_latest`, `reset_db`, `import_and_export_latest_for_antweb`

These are all destructive and can only be run in the dev env.

Commands:
```
RAILS_ENV=development ./script/db_dump/import data/db_dumps/antcat.2019-11-22T10-15-04.sql.gz
RAILS_ENV=development ./script/db_dump/import_latest
RAILS_ENV=development ./script/db_dump/reset_db
RAILS_ENV=development ./script/db_dump/import_and_export_latest_for_antweb
RAILS_ENV=development ./script/db_dump/interactive_import # Pick file from local db_dumps subdir
```
