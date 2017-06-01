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
sudo apt-get install ruby
```

#### Vagrant / Librarian-Chef (semi-automatic)
Copy the link to the latest Vagrant package from http://www.vagrantup.com/downloads.html
```bash
sudo apt-get install dpkg-dev virtualbox-dkms # VirtualBox
#replace vagrant_1.7.4_x86_64.deb with the latest vagrant package
wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4_x86_64.deb
sudo dpkg -i vagrant_1.7.4_x86_64.deb

sudo apt-get install linux-headers-$(uname -r) # try this if vagrant up fails
sudo dpkg-reconfigure virtualbox-dkms  # try this if vagrant up fails

sudo apt-get install nfs-kernel-server nfs-common # for network syncing
```

Optional, but recommended; this makes vagrant cache apt, gems and more
```bash
vagrant plugin install vagrant-cachier
```

Librarian-Chef
```bash
gem install librarian-chef
```

Then
```bash
vagrant plugin install vagrant-librarian-chef
```
or
```bash
librarian-chef install # possibly redundant
```

Running `vagrant up` will ask for your sudo password (for the `synced_folder`). To disable the prompt (and synced folder), uncomment this line: `config.vm.synced_folder '.', '/vagrant', nfs: true` in the [Vagrantfile](Vagrantfile).

Install/run Vagrant box. This can take a while.
Make sure you have edited `config/database.yml` before this step (and uncomment socket)
```bash
MYSQL_PASSWORD=secret123 vagrant up # downloads the 'precise64' box on the first run
# MYSQL_PASSWORD defaults to 'lasius' if not set
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
#### Seeds
```bash
bundle exec rake db:seed # contains tooltips
```

#### Sample data
```bash
bundle exec rake antcat:db:import_sample_data # imports sample data
```

## Run site
```bash
bundle exec rake sunspot:solr:start RAILS_ENV=development # start Solr
bundle exec rails server # start the app
```

Visit http://localhost:3000/

### Vagrant
```bash
vagrant up # boot Vagrant box if not already running
vagrant ssh
bundle exec rake sunspot:solr:start RAILS_ENV=development # start Solr
bundle exec rails server -b 0.0.0.0 # start the app
```

Visit http://192.168.50.50:3000/

## Run tests
```bash
bundle exec cucumber # feature/browser tests
bundle exec rspec    # unit tests
```