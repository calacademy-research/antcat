#!/usr/bin/env bash
git pull
docker-compose run antcat ./docker/download-database.sh
docker-compose down

