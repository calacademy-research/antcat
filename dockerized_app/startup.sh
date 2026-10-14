# Remove any pre-existing PID files
rm -rf /app/app/tmp/pids/server.pid
rm -f /app/tmp/pids/server.pid

chown -R antcat:antcat /app

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

