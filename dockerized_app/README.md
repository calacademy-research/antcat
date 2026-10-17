# antcat.org production (droplet `antcat-prod`)

This directory is the production setup, run from the checkout at `/var/www/antcat-2`
(git remote: `calacademy-research/antcat`, branch `master`). Until 2026-10-12 the server
ran a former volunteer's fork branch (`arthurjdam/antcat` `feat/add-nginx-conf`) plus edits
made directly on the server; those are now in this repo.

Containers (`docker compose` in this directory): `antcat-db` (MySQL), `antcat-app`
(Rails, production mode, code mounted from the checkout), `web` (nginx, ports 80/443),
`certbot` (Let's Encrypt renewal via Cloudflare DNS).

Not in git (see `.gitignore`), only on the server:
- `.env` with `ANTCAT_DB_PASSWORD=...` (MySQL root password, db container only) and
  `ANTCAT_APP_DB_USER=...` / `ANTCAT_APP_DB_PASSWORD=...` (the app's MySQL account); compose
  refuses to start without them
- `nginx/certbot/conf/` (certificates; also holds the CAS IT dmz-shield include files)
- `nginx/certbot/cloudflare/credentials.ini` (Cloudflare API token for DNS validation; mounted
  only into `certbot`, not into nginx)
- database data on the attached volume `/mnt/volume_sfo3_01/mysql`

Deploy a code change: `cd /var/www/antcat-2 && git pull && docker restart antcat-app`
(startup runs bundle install, yarn, asset precompile and Solr; allow a few minutes).
Never edit tracked files on the server; commit to GitHub instead.

Deploy a change to `Dockerfile` (e.g. a Ruby upgrade): a restart is not enough, the image must be rebuilt.
In this directory: `docker compose build app`, then `docker compose up -d app` (recreates `antcat-app`;
the first start compiles all gems into `vendor/bundle/ruby/<version>`: about 3 minutes on a 4-CPU CI runner, allow 10+ on the droplet), then
`docker compose exec web nginx -s reload` (nginx caches the old container's IP and returns 502 until reloaded).

Fresh setup (from the original README): `./setup_db.sh <sql file>`, then `docker compose build` and `docker compose up`.

nginx config change (`nginx/default.conf` or the `web` service in `docker-compose.yml`): the file is
bind-mounted, and `git pull` replaces it, so a reload alone may keep the old file. Check and apply with
`docker compose up -d --force-recreate web`, then `docker compose exec web nginx -t`. The visitor IP
comes from Cloudflare's `CF-Connecting-IP` only for Cloudflare's address ranges (`set_real_ip_from`).
