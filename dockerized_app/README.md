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
- `nginx/certbot/conf/` (certificates and TLS keys; also holds the CAS IT dmz-shield include files;
  mounted into `web` and `certbot`)
- `nginx/certbot/cloudflare/credentials.ini` (Cloudflare API token for DNS validation; mounted
  only into `certbot`)
- database data on the attached volume `/mnt/volume_sfo3_01/mysql84`

The app container mounts the whole checkout at `/app`, so `docker-compose.yml` covers `.env` (with
`/dev/null`) and `nginx/certbot/` (with an empty tmpfs) inside that container: the app cannot read the
MySQL root password, the Cloudflare token or the TLS keys. On the host these files are for root only:

```
chown root:root .env nginx/certbot/cloudflare/credentials.ini
chmod 600 .env nginx/certbot/cloudflare/credentials.ini
chmod 700 nginx/certbot/cloudflare nginx/certbot/conf/archive
```

Check: `stat -c '%a %U:%G %n' .env nginx/certbot/cloudflare/credentials.ini nginx/certbot/conf/archive`
shows `600 root:root`, `600 root:root`, `700 root:root`. A change to the app's mounts in `docker-compose.yml`
needs the container recreated (`docker compose up -d app`, then `docker compose exec web nginx -s reload`);
`docker restart antcat-app` keeps the old mounts.

Deploy a code change: `cd /var/www/antcat-2 && git pull && docker restart antcat-app`
(startup runs bundle install, yarn, asset precompile and Solr; allow a few minutes).
Never edit tracked files on the server; commit to GitHub instead.

The app runs as the user `antcat` (uid 1000, gid 1001), not root. `startup.sh` starts as root only to
hand `tmp/`, `log/`, `public/assets/` and `app/assets/builds/` to that user (and make
`config/settings/*.secret.yml` readable by group `antcat`, mode 640), and to run `bundle install` and
`yarn install` (gems and packages stay root-owned); the asset build and Puma then run as `antcat`
(`setpriv`). `docker exec antcat-app ...` still defaults to root; run Rails tasks and pipeline
scripts as the app user: `docker exec -u antcat antcat-app bundle exec rails runner ...`.

Deploy a change to `Dockerfile` (e.g. a Ruby upgrade): a restart is not enough, the image must be rebuilt.
In this directory: `docker compose build app`, then `docker compose up -d app` (recreates `antcat-app`;
the first start compiles all gems into `vendor/bundle/ruby/<version>`: about 3 minutes on a 4-CPU CI runner, allow 10+ on the droplet), then
`docker compose exec web nginx -s reload` (nginx caches the old container's IP and returns 502 until reloaded).

Fresh setup (from the original README): `./setup_db.sh <sql file>` (writes `mysql84-init/1-init.sql`, which MySQL loads on its first start with an empty data directory), then `docker compose build` and `docker compose up`.
On that first start MySQL also creates the database `antcat` and the app's account from `.env`
(`ANTCAT_APP_DB_USER` / `ANTCAT_APP_DB_PASSWORD`, all rights on `antcat` only; `MYSQL_USER` / `MYSQL_PASSWORD`
of the `db` service), so write `.env` first. An existing data directory is not changed by these settings.

nginx runs a pinned stable release (`image:` of `web` in `docker-compose.yml`). nginx applies a
per-visitor limit (10 requests/s with bursts of 60, 20 connections; over it: 429), and Rails sends
Strict-Transport-Security (`config.force_ssl`).

nginx config change (`nginx/default.conf` or the `web` service in `docker-compose.yml`): the file is
bind-mounted, and `git pull` replaces it, so a reload alone may keep the old file. Check and apply with
`docker compose up -d --force-recreate web`, then `docker compose exec web nginx -t`. The visitor IP
comes from Cloudflare's `CF-Connecting-IP` only for Cloudflare's address ranges (`set_real_ip_from`).
