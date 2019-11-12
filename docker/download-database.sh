#!/usr/bin/env bash
cd /code

grep -qxF "gem 'therubyracer'" Gemfile || echo "gem 'therubyracer'" >> Gemfile

git checkout db/schema.rb
gem install bundler
bundle install

chmod 600 ./docker/id_rsa

host_name="antcat.org"
username="deploy"
runcommand="ssh -i ././docker/id_rsa -o StrictHostKeyChecking=no $username@$host_name"
download_string=`$runcommand sudo -i eybackup -e mysql --list-backup antcat |   grep "9:antcat" | awk '{print $NF}'`
download_id=9
filename=$download_string
command="$runcommand sudo -i eybackup -e mysql -d $download_id:antcat"
$runcommand sudo -i eybackup -e mysql -d $download_id:antcat
mkdir -p /code/database_export
scp -i ././docker/id_rsa -o StrictHostKeyChecking=no $username@$host_name:/mnt/tmp/$filename /code/database_export
$runcommand sudo rm /mnt/tmp/$filename
mkdir -p /code/database_archive
cp /code/database_export/$filename /code/database_archive
gunzip -f /code/database_export/$filename

unzipped=`echo $filename | rev | cut -c 4- | rev`
perl -p -i -e "s/mysql -u root/mysql -h db -u root/g" /code/script/*.sh
echo "Unzipped: $unzipped"

echo -e "development:\n\
  adapter: mysql2\n\
  encoding: utf8\n\
  database: antcat\n\
  username: root\n\
  host: db\n\
  port: 3306\n" > /code/config/database.yml

cd /code/script
./reset_database.sh
./load.sh /code/database_export/$unzipped
cd /code
bundle exec rake antweb:export
cp /code/data/output/antcat.antweb.txt /code/database_export/antcat.antweb.txt
rm /code/database_export/$unzipped
