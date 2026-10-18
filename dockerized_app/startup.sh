#!/bin/bash
# Starts antcat.org in the `antcat-app` container (see docker-compose.yml).
#
# This script starts as root, but only for the steps that need it: handing the writable directories
# to the `antcat` user, and installing gems and JavaScript packages (vendor/bundle and node_modules
# stay root-owned, so the running app cannot change its own code or dependencies). The asset build
# and Puma run as `antcat` (uid 1000, created in the Dockerfile).
#
# `docker exec antcat-app ...` still runs as root by default. For Rails tasks that touch the cache or
# write files (pipelines, rake tasks), prefer `docker exec -u antcat antcat-app ...`; any root-owned
# files left in tmp/ or log/ are handed back to `antcat` on the next start.
set -e

APP_USER=antcat

if ! command -v setpriv > /dev/null; then
  echo "startup.sh: setpriv (util-linux) is missing; refusing to start the app as root." >&2
  exit 1
fi

# Runs a command as the app user, keeping the container environment (database settings, Bundler
# paths, LANG) and setting HOME so Bundler and Yarn do not try to write to /root.
run_as_app_user() {
  setpriv --reuid="$APP_USER" --regid="$APP_USER" --init-groups -- \
    env HOME="/home/$APP_USER" USER="$APP_USER" "$@"
}

# Remove any pre-existing PID files
rm -rf /app/app/tmp/pids/server.pid
rm -f /app/tmp/pids/server.pid

# Only the directories the app writes are handed to the `antcat` user. /app is the host checkout
# (/var/www/antcat-2), which also holds dockerized_app/.env and the TLS keys; do not re-own all of it.
APP_WRITABLE_DIRS="/app/tmp /app/log /app/public/assets /app/app/assets/builds"
mkdir -p $APP_WRITABLE_DIRS
chown -R "$APP_USER:$APP_USER" $APP_WRITABLE_DIRS

# Server-only settings files (gitignored) must be readable by the app user, and by nobody else.
for secret_file in /app/config/settings/*.secret.yml; do
  [ -f "$secret_file" ] || continue
  chgrp "$APP_USER" "$secret_file"
  chmod g+r,o-rwx "$secret_file"
done

cd /app
# Install gems into vendor/bundle (`bundle install --path` is deprecated and removed in Bundler 4).
# Runs as root: the app user can read the installed gems but not change them.
bundle config set --local path vendor/bundle
bundle install
yarn install

cd /app/app
# Packages were installed above; skip the second `yarn install` that jsbundling/cssbundling would run
# (node_modules is not writable by the app user).
run_as_app_user env SKIP_YARN_INSTALL=1 bundle exec rake assets:precompile

# Search runs in its own container (service `solr`, Solr 10); see docker-compose.yml.

# Start the Rails server as the app user, binding it to all network interfaces. `exec` lets Puma
# receive the container's stop signal directly.
exec setpriv --reuid="$APP_USER" --regid="$APP_USER" --init-groups -- \
  env HOME="/home/$APP_USER" USER="$APP_USER" bundle exec rails s -p 8080 -b '0.0.0.0'
