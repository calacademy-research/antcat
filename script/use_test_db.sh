mysqldump -u root antcat_test > antcat_changes.sql
mysql -u root -e "drop database antcat;"
mysql -u root -e "create database antcat;"
mysql -u root antcat   < antcat_changes.sql
~/antcat/script/create_user.sh
