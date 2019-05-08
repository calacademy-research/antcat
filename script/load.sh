# This is used for the AntWeb export.
./reset_database.sh
echo "Loading $1"
mysql -u root antcat < $1
rake db:migrate
