#!/usr/bin/env bash
cd /code

grep -qxF "gem 'therubyracer'" Gemfile || echo "gem 'therubyracer'" >> Gemfile

git checkout db/schema.rb
gem install bundler
bundle install

chmod 600 ./docker/id_rsa
host_name="ec2-52-24-122-198.us-west-2.compute.amazonaws.com"
host_name="antcat.org"
username="deploy"
runcommand="ssh -i ././docker/id_rsa -o StrictHostKeyChecking=no $username@$host_name"
download_string=`$runcommand sudo -i eybackup -e mysql --list-backup antcat |   grep "9:antcat" | cut -c3-`
echo "download string:" $download_string
download_id=`echo $download_string | head -c 2`
filename=`echo $download_string | awk '/[0-9:a-zA-Z]+ ([a-zA-Z.\-0-9]*)/{ print $2 }'`
echo downloading.... $filename
$runcommand sudo -i eybackup -e mysql -d $download_id:antcat
mkdir -p /code/database_export
scp -i ././docker/id_rsa -o StrictHostKeyChecking=no $username@$host_name:/mnt/tmp/$filename /code/database_export
mkdir -p /code/database_archive
cp /code/database_export/$filename /code/database_archive
gunzip -f /code/database_export/$filename

unzipped=`echo $filename | rev | cut -c 4- | rev`
perl -p -i -e "s/mysql -u root/mysql -h db -u root/g" /code/script/*.sh
echo "Unzipped: $unzipped"

cd /code/script
./reset.sh
./load.sh /code/database_export/$unzipped
cd /code
echo -e "development:\n\
  adapter: mysql2\n\
  encoding: utf8\n\
  database: antcat\n\
  username: root\n\
  host: db\n\
  port: 3306\n" > /code/config/database.yml
bundle exec rake antweb:export
cp /code/data/output/antcat.antweb.txt /code/database_export/antcat.antweb.txt
rm /code/database_export/$unzipped
