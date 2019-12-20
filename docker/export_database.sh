#!/usr/bin/env bash
git fetch origin
git fetch --all
git reset --hard origin/master
git pull
docker-compose build
docker-compose run antcat ./docker/download-database.sh
docker-compose down

