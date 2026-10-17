# Remove any pre-existing PID files
rm -rf /app/app/tmp/pids/server.pid
rm -f /app/tmp/pids/server.pid

# Only the directories the app writes are handed to the `antcat` user. /app is the host checkout
# (/var/www/antcat-2), which also holds dockerized_app/.env and the TLS keys; do not re-own all of it.
# (Bundler writes vendor/bundle and yarn node_modules; both still run as root here.)
APP_WRITABLE_DIRS="/app/tmp /app/log /app/public/assets /app/app/assets/builds"
mkdir -p $APP_WRITABLE_DIRS
chown -R antcat:antcat $APP_WRITABLE_DIRS

cd /app
# Install gems into vendor/bundle (`bundle install --path` is deprecated and removed in Bundler 4).
bundle config set --local path vendor/bundle
bundle install
yarn install

cd /app/app
bundle exec rake assets:precompile

# Search runs in its own container (service `solr`, Solr 10); see docker-compose.yml.

# Start the Rails server, binding it to all network interfaces
bundle exec rails s -p 8080 -b '0.0.0.0'

