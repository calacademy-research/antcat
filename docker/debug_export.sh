#!/usr/bin/env bash
git pull

docker-compose run antcat bash
docker-compose down
