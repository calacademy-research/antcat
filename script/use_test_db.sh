mysqldump -u root antcat_test > antcat_changes.sql
./reset_database.sh
mysql -u root antcat   < antcat_changes.sql
~/antcat/script/create_user.sh
