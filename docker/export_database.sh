#!/usr/bin/env bash
docker system prune -f --volumes
git fetch origin
git fetch --all
git reset --hard origin/master
git pull
echo "Starting build..."
docker-compose build
echo "Starting download database compose run"
docker-compose run antcat ./docker/download-database.sh
docker-compose down
docker system prune -f --volumes
