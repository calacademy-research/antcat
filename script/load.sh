./reset_database.sh
echo "Loading $1"
mysql -u root antcat   < $1
rake db:migrate
~/antcat/script/create_user.sh
