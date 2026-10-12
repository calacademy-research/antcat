# Runs once, when the MySQL 8.4 data directory is first created (copied into ./mysql84-init).
# The app container's client library (Debian's MariaDB Connector/C) is most reliable with
# mysql_native_password, so keep root on it (needs --mysql-native-password=ON).
mysql --protocol=socket -uroot -p"$MYSQL_ROOT_PASSWORD" <<SQL
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
SQL
