./reset_database.sh
echo "Loading $1"
mysql -u root antcat   < $1
~/antcat/script/create_user.sh
