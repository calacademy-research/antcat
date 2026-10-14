#### Build
```sh
docker-compose build
# Or with custom uid/gid:
docker-compose build --build-arg ANTCAT_UID="$(id -u)" --build-arg ANTCAT_GID="$(id -g)"
```

#### Setup env and database
```sh
docker-compose run app /bin/bash

bundle install --path=vendor/bundle
yarn install

bundle exec rails db:create
bundle exec rails db:migrate

bundle exec rails seed:catalog # Sample data.

exit
```

#### Launch site
```sh
docker-compose run -p 3000:3000 app /bin/bash

bundle config path vendor/bundle
# Search: Solr 10 in Docker (cores `development` and `test`, ports from config/sunspot.yml):
#   docker run -d --name antcat-solr-dev -p 8982:8983 -p 8981:8983 -e SOLR_MODE=user-managed \
#     -v "$PWD/solr/configsets/antcat:/configsets/antcat:ro" solr:10.0 \
#     bash -c 'precreate-core development /configsets/antcat; precreate-core test /configsets/antcat; exec solr-foreground'
bundle exec rails s -p 3000 -b '0.0.0.0'
```
