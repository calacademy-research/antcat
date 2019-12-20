#!/usr/bin/env bash
rm -rf ../db/schema.rb Gemfile Gemfile.lock
git fetch --all
perl -p -i -e "s/ruby \'2.3.3\'/ruby \'2.4.0\'/g" ../Gemfile
#git pull
docker-compose run antcat ./docker/download-database.sh
docker-compose down

