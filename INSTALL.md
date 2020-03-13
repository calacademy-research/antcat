## Installation (Linux, work in progress)

```bash
git clone https://github.com/calacademy/antcat.git
cd antcat
cp config/database.yml.example config/database.yml # edit database.yml
cp config/server.yml.example config/server.yml
cp config/secrets.yml.example config/secrets.yml
```

### Install dependencies
## Basic deps
```bash
sudo apt-get install git
```

#### Manual installation
First install RVM, Apache Solr, MySQL, curl, NodeJs (use Google).

```bash
bundle install # install gems
```
### Database
```bash
bundle exec rake db:create && rake db:schema:load
bundle exec rake db:test:prepare
```

#### Sample data
```bash
bundle exec rake dev:prime
```

## Run site
```bash
bundle exec rake sunspot:solr:start RAILS_ENV=development
bundle exec rails server
```

Visit http://localhost:3000/

## Run tests
```bash
bundle exec cucumber # feature/browser tests
bundle exec rspec    # unit tests
```