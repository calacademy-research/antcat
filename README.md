#AntCat
##California Academy of Sciences
Ant taxonomy database -- http://antcat.org/

                                                      |   /
                                                       \  |
                                                        \_|
                        _    _____      _          __  /` ;
            /\         | |  / ____|    | |       `'  \ `\_/ _
           /  \   _ __ | |_| |     __ _| |_           '-/ \/ '._
          / /\ \ | '_ \| __| |    / _` | __|       /'-./| |.--. `
         / ____ \| | | | |_| |___| (_| | |_      _/  _.-\/--.  |
        /_/    \_\_| |_|\__|\_____\__,_|\__|    `   |   /`-. \ '-.
                                                    |   |   | \
                                                   /    |   /  `-.
                                                 -'     \__/
                                                 
##Installation (work in progress)
```bash
git clone https://github.com/calacademy/antcat.git
cd antcat
cp config/database.yml.example config/database.yml # edit database.yml
cp config/server.yml.example config/server.yml
cp config/secrets.yml.example config/secrets.yml #TODO this file does not exist in the main repo
```

###Install dependencies
####Vagrant / Librarian-Chef (semi-automatic)
```bash
sudo apt-get install dpkg-dev virtualbox-dkms
```

Copy the link to the latest Vagrant package from http://www.vagrantup.com/downloads.html
```bash
#replace vagrant_1.7.4_x86_64.deb with the latest vagrant package
wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4_x86_64.deb
sudo dpkg -i vagrant_1.7.4_x86_64.deb

sudo apt-get install linux-headers-$(uname -r)
sudo dpkg-reconfigure virtualbox-dkms
```

Optional, but highly recommended; this makes vagrant cache apt, gems and more
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

####Manual installation
First install RVM, Apache Solr, MySQL, curl, NodeJs (use Google).

Install gems
```bash
bundle install
```
###Database
```bash
bundle exec rake db:create && rake db:schema:load
bundle exec rake db:test:prepare
```

##Usage
Start Vagrant
```bash
vagrant up # if not already running
vagrant ssh
```

Start Solr
```bash
bundle exec rake sunspot:solr:start RAILS_ENV=development
```

Start the app
```bash
bundle exec rails server -b 0.0.0.0    # if Vagrant
bundle exec rails server               # without Vagrant
```

Visit http://192.168.50.50:3000/ (Vagrant) or http://localhost:3000/ (without Vagrant)

##Contributing
[Contributions](CONTRIBUTING.md) welcome!
