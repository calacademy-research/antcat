# This is used for the AntWeb export.
./reset_database.sh
echo "Loading $1"
mysql -h db -u root antcat < $1
rake db:migrate
