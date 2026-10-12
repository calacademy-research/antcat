# antcat.org production (droplet `antcat-prod`)

This directory is the production setup, run from the checkout at `/var/www/antcat-2`
(git remote: `calacademy-research/antcat`, branch `master`). Until 2026-10-12 the server
ran a former volunteer's fork branch (`arthurjdam/antcat` `feat/add-nginx-conf`) plus edits
made directly on the server; those are now in this repo.

Containers (`docker compose` in this directory): `antcat-db` (MySQL), `antcat-app`
(Rails, production mode, code mounted from the checkout), `web` (nginx, ports 80/443),
`certbot` (Let's Encrypt renewal via Cloudflare DNS).

Not in git (see `.gitignore`), only on the server:
- `.env` with `ANTCAT_DB_PASSWORD=...` (MySQL root password; compose refuses to start without it)
- `nginx/certbot/conf/` (certificates; also holds the CAS IT dmz-shield include files)
- `nginx/certbot/cloudflare/credentials.ini` (Cloudflare API token for DNS validation)
- database data on the attached volume `/mnt/volume_sfo3_01/mysql`

Deploy a code change: `cd /var/www/antcat-2 && git pull && docker restart antcat-app`
(startup runs bundle install, yarn, asset precompile and Solr; allow a few minutes).
Never edit tracked files on the server; commit to GitHub instead.
