#!/bin/bash

set -e

# Config
REMOTE_USER=root
REMOTE_HOST=antcat.org
REMOTE_PATH=/tmp
KEY=./docker/id_rsa_digitalocean
LOCAL_EXPORT=/code/database_export
LOCAL_ARCHIVE=/code/database_archive

# Timestamped filename
TIMESTAMP=$(date +"%Y-%m-%dT%H-%M-%S")
FILENAME="antcat.${TIMESTAMP}.sql.gz"

echo "Creating gzipped database dump on remote server..."
ssh -i "$KEY" -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} \
  "docker exec antcat-db sh -c 'exec mysqldump -uroot -ppassword --single-transaction --quick --lock-tables=false antcat' | gzip > ${REMOTE_PATH}/${FILENAME}"

echo "Downloading database dump..."
mkdir -p "$LOCAL_EXPORT"
scp -i "$KEY" -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/${FILENAME} ${LOCAL_EXPORT}/

echo "Removing remote dump..."
ssh -i "$KEY" -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} \
  "rm -f ${REMOTE_PATH}/${FILENAME}"

echo "Archiving dump..."
mkdir -p "$LOCAL_ARCHIVE"
cp ${LOCAL_EXPORT}/${FILENAME} ${LOCAL_ARCHIVE}/

echo "Unzipping dump..."
gunzip -f ${LOCAL_EXPORT}/${FILENAME}
UNZIPPED=$(echo "$FILENAME" | sed 's/\.gz$//')

echo "Writing config/database.yml..."
cat > /code/config/database.yml <<EOF
development:
  adapter: mysql2
  encoding: utf8
  database: antcat
  username: root
  host: db
  port: 3306
EOF

echo "Resetting and loading database..."
cd /code/script
./reset_database.sh
./load.sh ${LOCAL_EXPORT}/${UNZIPPED}

cd /code
echo "Exporting antweb data..."
bundle exec rake antweb:export
cp /code/data/output/antcat.antweb.txt ${LOCAL_EXPORT}/antcat.antweb.txt

rm ${LOCAL_EXPORT}/${UNZIPPED}

