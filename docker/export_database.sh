#!/usr/bin/env bash
rm -rf ../db/schema.rb Gemfile Gemfile.lock
git fetch --all
#git pull
docker-compose run antcat ./docker/download-database.sh
docker-compose down

