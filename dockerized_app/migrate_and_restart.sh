#!/bin/bash
# Deploy step after `git pull` on antcat-staging and antcat-prod (checkout /var/www/antcat-2):
# runs pending database migrations, with a database dump first, then restarts the app.
#
#   cd /var/www/antcat-2 && git rev-parse HEAD > /root/antcat-rollback-commit.txt && git pull -q \
#     && bash dockerized_app/migrate_and_restart.sh
#
# 1. Asks Rails for the migration status (`db:migrate:status`). When the new code needs gems that are
#    not installed yet (Gemfile changed), the status fails: the app is restarted first (startup.sh runs
#    `bundle install`) and the status is asked again once the app is up.
# 2. No pending migration: nothing is dumped or migrated; the app is restarted (the normal deploy).
# 3. Pending migrations: mysqldump of the `antcat` database from the `antcat-db` container to
#    $BACKUP_DIR/antcat-before-migrate-<date>.sql.gz, checked (gzip valid, more than 1 MB, ends with
#    mysqldump's "Dump completed" line); stops if the check fails. Then `bin/rails db:migrate` in
#    `antcat-app` as the app user, then a restart.
#
# The MySQL root password is read inside the db container from its own environment; it is never
# printed or passed on the command line. Production does not rewrite db/schema.rb after migrating
# (`dump_schema_after_migration = false`), so no tracked file changes on the server.
#
# Rollback (printed again at the end when migrations ran):
#   code:     git checkout -q $(cat /root/antcat-rollback-commit.txt) && docker restart antcat-app
#   database: gunzip -c <dump file> | docker exec -i antcat-db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot antcat'
#             (only when a migration changed data or cannot be reversed; otherwise
#             `docker exec -u antcat antcat-app bin/rails db:rollback STEP=<n>` before the code rollback)
set -euo pipefail

APP_CONTAINER=${APP_CONTAINER:-antcat-app}
DB_CONTAINER=${DB_CONTAINER:-antcat-db}
DB_NAME=${DB_NAME:-antcat}
BACKUP_DIR=${BACKUP_DIR:-/root/antcat-db-backups}
MIN_DUMP_BYTES=${MIN_DUMP_BYTES:-1000000}
WAIT_FOR_APP_SECONDS=${WAIT_FOR_APP_SECONDS:-1200}

log() { echo "[migrate_and_restart $(date '+%F %T')] $*"; }

rails_in_app() {
  docker exec -u antcat -w /app "$APP_CONTAINER" bundle exec rails "$@"
}

migration_status() {
  rails_in_app db:migrate:status 2> /dev/null
}

restart_app() {
  log "Restarting $APP_CONTAINER (startup takes a few minutes)."
  docker restart "$APP_CONTAINER" > /dev/null
}

if ! status=$(migration_status); then
  log "Could not read the migration status (gems not installed yet?). Restarting the app first."
  restart_app
  waited=0
  until status=$(migration_status); do
    if [ "$waited" -ge "$WAIT_FOR_APP_SECONDS" ]; then
      log "FAILED: still no migration status after ${WAIT_FOR_APP_SECONDS}s. Check: docker logs --tail 50 $APP_CONTAINER"
      exit 1
    fi
    sleep 30
    waited=$((waited + 30))
  done
fi

pending=$(printf '%s\n' "$status" | grep -E '^[[:space:]]*down[[:space:]]' || true)

if [ -z "$pending" ]; then
  log "No pending migrations. No dump, no migration."
  restart_app
  log "Done."
  exit 0
fi

log "Pending migrations:"
printf '%s\n' "$pending"

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"
dump_file="$BACKUP_DIR/antcat-before-migrate-$(date '+%Y%m%d-%H%M%S').sql.gz"

log "Dumping database $DB_NAME to $dump_file"
# shellcheck disable=SC2016 # $MYSQL_ROOT_PASSWORD is expanded inside the db container.
umask 077
if ! docker exec "$DB_CONTAINER" sh -c \
  'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysqldump -uroot --single-transaction --quick --routines --triggers --no-tablespaces "$1"' \
  sh "$DB_NAME" | gzip > "$dump_file"; then
  log "FAILED: mysqldump. Nothing was migrated; the app was not restarted."
  exit 1
fi

dump_bytes=$(stat -c %s "$dump_file")
if ! gzip -t "$dump_file" \
  || [ "$dump_bytes" -lt "$MIN_DUMP_BYTES" ] \
  || ! gunzip -c "$dump_file" | tail -n 1 | grep -q 'Dump completed'; then
  log "FAILED: the dump $dump_file looks incomplete ($dump_bytes bytes). Nothing was migrated; the app was not restarted."
  exit 1
fi
log "Dump OK ($dump_bytes bytes)."

log "Running db:migrate"
if ! rails_in_app db:migrate; then
  log "FAILED: db:migrate. The app was not restarted. Dump: $dump_file"
  exit 1
fi

rails_in_app db:migrate:status | tail -n 5
restart_app

log "Done. Dump kept at $dump_file"
log "Rollback, if needed: see the comment at the top of dockerized_app/migrate_and_restart.sh"
