# AntCat data flows

Where AntCat's data comes from, where it goes, and what runs on its own. The tables are explained in
`docs/data-model.md`; every page and route in `docs/catalog/routes.tsv`.

```
editors and helpers ──(web forms)──> MySQL (antcat-db) ──> Solr (antcat-solr): search
                                         │
                                         ├──> catalog pages, /v1 API (read only) ──> visitors, scripts
                                         │
                                         └──(nightly dump over the private network)──> antcat-export
                                                                                         │ rake antweb:export
                                                                                         v
                                                                           antcat.antweb.txt (port 9090)
                                                                                         │ 05:00 Pacific
                                                                                         v
                                                                                       AntWeb
```

## 1. Editing (the only way data comes in)

- Who: signed-in users with the right (`users.helper`, `editor`, `superadmin`). The rights each page needs are the
  `who` column of `docs/catalog/routes.tsv`, read from the controllers' `before_action` checks.
- What is written: the taxonomy and reference tables (`taxa`, `protonyms`, `names`, `history_items`, `references`
  and the tables around them), through the forms of the site. There is no import of taxonomy from another source
  in this app; the scripts that compare AntCat with TaxonWorks and with Bolton's catalog are kept outside this
  repository and run inside the app container.
- What every save also writes:
  - a row of `versions` for each changed row (paper_trail: who, the old values, the changes), grouped by
    `request_uuid`; that is the revision history of each record;
  - a row of `activities` (the feed at `/activities`) with the user's edit summary;
  - the Solr index of the changed taxa, protonyms and references (sunspot), so search finds the new state.
- Database scripts (`/database_scripts`) list records that look wrong (soft validations); editors fix them by hand.
  They change nothing themselves.

## 2. Reading

- The catalog pages, the references and the search are public. Search uses Solr (`antcat-solr`); if Solr is
  down, search fails and the rest of the site works. `script/solr/restart_and_reindex` rebuilds the index from MySQL.
- The API (`/v1`, 29 routes, all GET): JSON of the same tables, read only. Optional free keys
  (`Settings.api_keys.enabled`, off by default): when on, every request but the front door is counted
  (`api_usage_days`, `api_usage_minutes`) and limited per key or per visitor (`app/services/api_access.rb`).
  Registration (`/api_keys/new`) writes `api_keys` and sends the confirmation email.
- Cloudflare is in front of antcat.org; nginx (`dockerized_app/nginx`) in front of Puma.

## 3. To AntWeb (every night)

1. 03:00 Pacific, on the droplet antcat-export: `docker/export_database.sh` resets its checkout of this repository to
   `origin/master` and starts a throwaway stack (`docker/docker-compose.yml`: Ruby and MySQL 8.4).
2. `docker/download-database.sh` dumps the production database on antcat-prod over the private network
   (`mysqldump --single-transaction`, so the site keeps working), copies it back and loads it. A dated copy of the
   dump is kept for 7 days on that droplet.
3. `rake antweb:export` (`app/services/exporters/antweb`) writes one line per taxon of every rank but subtribe and
   infrasubspecies: the AntCat id, the ranks above it, author and year, status, availability, the current valid
   name, rank and parent, the original combination, fossil, the taxonomic history (HTML), the reference id, bioregion,
   country and the Hymenoptera Online id (`ExportTaxon::HEADER` lists the 24 columns). It writes to a temporary file and puts
   it in place only when complete, so a failed run leaves the previous file.
4. The file, `antcat.antweb.txt`, is served on port 9090 of antcat-export.
5. 05:00 Pacific: AntWeb's nightly set 1 fetches it ("WorldAnts" import) and updates its taxon names. AntWeb never
   writes to AntCat.

Planned (CAS IT, 2026-11-13, in steps over a few weeks): the export runs on antcat-prod itself (`rake antweb:export` in
the app container at 01:30 Pacific, the file served on the private network only); AntWeb's address for it changes
once seven nights match, and the antcat-export droplet is retired. This section is rewritten when that is done.

## 4. Email

Sent by the app over SMTP (`Settings.smtp_settings`, a server-only file):

- sign-up and password emails (Devise, `app/mailers/sign_up_mailer.rb`);
- notifications of replies and mentions to users who allow them (`user_mailer.rb`, `notifications`);
- the API key confirmation, and a copy of each registration to `Settings.api_keys.registration_copy_to`
  (`api_key_mailer.rb`).

## 5. Backups and copies

- The nightly dump of step 3 is a full copy of the database (7 days kept on antcat-export).
- `script/db_dump/` has the scripts to download the latest dump and load it locally (development).
- Uploaded reference PDFs (`reference_documents`) are stored on Amazon S3 (`References::DocumentStorage`), not in the
  database or its dump; the row holds the file name or an outside link.

## 6. Deploys

No automatic deploy. `script/deploy` (staging first, then production) records the running commit for rollback,
checks out the new one, restarts the app container and checks `/v1`, a catalog page and the home page. CI
(`.github/workflows/main.yml`) runs RSpec on MySQL 8.4, RuboCop, migrations, the security scan and the deploy
script's own tests on every push.
