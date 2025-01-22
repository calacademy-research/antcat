#!/bin/bash

# Variables
BASE_DIR=$(dirname "$0")
SQL_DATA_DIR="${BASE_DIR}/sql-data"
DB_DUMP=$1
DB_NAME="antcat"

rm -rf $SQL_DATA_DIR

# Ensure the argument is provided
if [ -z "$DB_DUMP" ]; then
  echo "Usage: $0 <path-to-database-dump>"
  exit 1
fi

# Create sql-data directory if it doesn't exist
mkdir -p "$SQL_DATA_DIR"

# Check if the dump file is compressed and handle accordingly
if [[ "$DB_DUMP" == *.gz ]]; then
  echo "Unzipping database dump..."
  gunzip -c "$DB_DUMP" > "${SQL_DATA_DIR}/${DB_NAME}.sql"
elif [[ "$DB_DUMP" == *.sql ]]; then
  echo "Copying SQL dump to sql-data..."
  cp "$DB_DUMP" "${SQL_DATA_DIR}/${DB_NAME}.sql"
else
  echo "Unsupported file type. Provide a .sql or .gz file."
  exit 1
fi

# Prepend CREATE and USE statements to the SQL file
INIT_FILE="${SQL_DATA_DIR}/1-init.sql"
DUMP_FILE="${SQL_DATA_DIR}/${DB_NAME}.sql"

echo "Generating initialization SQL..."
cat <<EOF > "$INIT_FILE"
CREATE DATABASE IF NOT EXISTS $DB_NAME;
USE $DB_NAME;
EOF

# Append the original dump content to the init file
cat "$DUMP_FILE" >> "$INIT_FILE"

# Remove the original unzipped dump file to avoid duplicate execution
rm "$DUMP_FILE"

echo "Setup complete. Initialization scripts are in $SQL_DATA_DIR."

