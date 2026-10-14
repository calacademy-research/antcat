# This is used for the AntWeb export.
# --skip-ssl: the export image's MariaDB client (Debian 13) verifies TLS by default and rejects the
# throwaway mysql:8.4 container's self-signed certificate; the connection never leaves the Docker network.
mysql --skip-ssl -h db -u root -e "drop database antcat;"
mysql --skip-ssl -h db -u root -e "create database antcat;"
