#!/usr/bin/env bash
docker system prune -f --volumes
git fetch origin
git fetch --all
git reset --hard origin/master
git pull
echo "Starting build..."
# Stop if the build fails: the old image would run with outdated gems (2026-10-15).
if ! docker-compose build; then
  echo "BUILD FAILED $(date) - export not run. Check disk space: df -h /"
  docker system prune -f --volumes
  exit 1
fi
echo "Starting download database compose run"
docker-compose run antcat ./docker/download-database.sh
docker-compose down
docker system prune -f --volumes
