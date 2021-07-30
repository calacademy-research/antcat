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
bundle exec rails sunspot:solr:start
bundle exec rails s -p 3000 -b '0.0.0.0'
```
