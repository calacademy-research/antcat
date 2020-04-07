#!/bin/bash
cd "$(dirname "$0")"
database_export_dir='../database_archive'
db_file=`ls -Art $database_export_dir | tail -n 1`
echo "Found: $database_export_dir/$db_file"
if [[ $(find "$database_export_dir/$db_file" -mtime +1 -print) ]]; then
  echo "Database export file $db_file exists and is older than 1 day"
  exit 2
else
  echo "Database export $db_file exists and is young."
fi



filename=$PWD/antcat.antweb.txt
echo "Checking on $filename"
if [ ! -f "$filename" ]; then
  echo "File $filename is missing"
  exit 1
fi

#if [[ $(find "$filename" -mmin +999 -print) ]]; then
if [[ $(find "$filename" -mtime +1 -print) ]]; then
  echo "File $filename exists and is older than 1 day"
  exit 2
else
  echo "File $filename exists and is young."
  exit 0
fi
