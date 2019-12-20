This Dockerfile was added solely for the AntWeb Export.

Downloading the latest db dump requires SSH access to EngineYard. Make sure `antweb_export_rsa` contains a valid key.

### Download and import latest db dump, and create AntWeb export

```sh
docker-compose -f docker/antweb-export.docker-compose.yml down --volumes &&
  docker-compose -f docker/antweb-export.docker-compose.yml build --build-arg SSH_PRIVATE_KEY="$(cat antweb_export_rsa)" &&
  docker-compose -f docker/antweb-export.docker-compose.yml run antweb_export script/db_dump/import_and_export_latest_for_antweb &&
  docker-compose -f docker/antweb-export.docker-compose.yml down --volumes
```

Export will be generated in `data/antweb_exports/antcat.antweb.txt`.

See also `antcat.antweb.txt.stderr.log`  and `antcat.antweb.txt.stdout.log`.

### Launch terminal
```sh
docker-compose -f docker/antweb-export.docker-compose.yml run antweb_export /bin/bash
```
