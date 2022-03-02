#!/usr/bin/env bash
echo "Starting download database inside docker..."
cd /code

bundle install # TODO: Probably not required any longer.

chmod 600 ./docker/id_rsa

host_name="antcat.org"
username="deploy"
runcommand="ssh -i ././docker/id_rsa -o StrictHostKeyChecking=no $username@$host_name"

# Get "backup index" and figure out filenames and such.
# `most_recent_db_dump looks` like this: "9:antcat antcat.2019-10-11T10-15-04.sql.gz"
most_recent_db_dump=$($runcommand sudo -i eybackup --list-backup antcat | grep -P "\d:antcat" | tail -n 1)
download_id=$(echo "$most_recent_db_dump" | cut -d ' ' -f 1) # <-- "9:antcat".
filename=$(echo "$most_recent_db_dump" | cut -d ' ' -f 2) # <-- "antcat.2019-10-11T10-15-04.sql.gz".

$runcommand sudo -i eybackup -e mysql -d $download_id:antcat
mkdir -p /code/database_export
scp -i ././docker/id_rsa -o StrictHostKeyChecking=no $username@$host_name:/mnt/tmp/$filename /code/database_export
$runcommand sudo rm /mnt/tmp/$filename
mkdir -p /code/database_archive
cp /code/database_export/$filename /code/database_archive
gunzip -f /code/database_export/$filename

unzipped=`echo $filename | rev | cut -c 4- | rev`
echo "Unzipped: $unzipped"

echo -e "development:\n\
  adapter: mysql2\n\
  encoding: utf8\n\
  database: antcat\n\
  username: root\n\
  host: db\n\
  port: 3306\n" > /code/config/database.yml

cd /code/script
echo "Resetting database..."
./reset_database.sh
echo "Loading new data..."
./load.sh /code/database_export/$unzipped

cd /code
echo "Starting export..."
bundle exec rake antweb:export
cp /code/data/output/antcat.antweb.txt /code/database_export/antcat.antweb.txt
rm /code/database_export/$unzipped
