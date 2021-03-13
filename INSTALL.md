## Install

### Grab the code

```bash
git clone https://github.com/calacademy/antcat.git
```

### Dependencies

* git
* [rvm](https://rvm.io/rvm/install)
* [nvm](https://github.com/nvm-sh/nvm)
* [yarn](https://github.com/yarnpkg/yarn)
* MySQL
* Java runtime (for Apache Solr)

### Config and install

```bash
cp config/database.yml.example config/database.yml
cp config/server.yml.example config/server.yml
```

#### Ruby gems and npm packages

```bash
bundle install
rake yarn:install
```

#### Setup database
```bash
rake db:create
rake db:schema:load
rake db:test:prepare
```

---

#### Sample data
```bash
rake seed:catalog
```

See also `rake antcat`.

#### Run site
```bash
RAILS_ENV=development rake sunspot:solr:start
rails server
```

Visit http://localhost:3000/

#### Run tests
```bash
cucumber
rspec
```
