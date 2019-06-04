#!/usr/bin/env bash
MYPWD=${PWD} 
cd "$(dirname "$0")"
pwd=$pwd
cd ./antcat
git checkout db/schema.rb
git pull
bundle install
cd $MYPWD
