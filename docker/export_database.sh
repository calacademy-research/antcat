#!/usr/bin/env bash
rm -rf ../db/schema.rb ../Gemfile ../Gemfile.lock
git fetch origin
git fetch --all
git reset --hard origin/master
git pull
perl -p -i -e "s/ruby \'2.3.3\'/ruby \'2.4.0\'/g" ../Gemfile
docker-compose run antcat ./docker/download-database.sh
docker-compose down

