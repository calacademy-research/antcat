## Install

### Grab the code
```sh
git clone https://github.com/calacademy/antcat.git
```

## Install locally in Docker container
See [`docker_dev/README.md`](docker_dev/README.md)

## Install locally with native dependencies

### Dependencies
* git
* [rvm](https://rvm.io/rvm/install)
* [nvm](https://github.com/nvm-sh/nvm)
* [yarn](https://github.com/yarnpkg/yarn)
* MySQL
* Java runtime (for Apache Solr)

### Config and install
```sh
cp config/database.yml.example config/database.yml
cp config/server.yml.example config/server.yml
```

#### Ruby gems and npm packages
```sh
bundle install
rails yarn:install
```

#### Setup database
```sh
rails db:create
rails db:schema:load
rails db:test:prepare
```

---

#### Sample data
```sh
rails seed:catalog
```

See also `rake antcat`

#### Launch site
```sh
rails sunspot:solr:start
rails server
```

Visit http://localhost:3000/

#### Run tests
```sh
rspec
```
