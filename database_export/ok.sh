#!/bin/bash
cd "$(dirname "$0")"
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
