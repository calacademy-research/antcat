tl;dr:
Add "id_rsa" for your engineyard profile, so you can download databases.
Run "export_database.sh". Results in /database_export.


-------------

This uses docker compose to export the database. It requires a clean checkout of antcat.
Updating ruby versions will require a change to antcat-database.docker.
This is based
on the docker image "ruby-<version>", which is derived from debian.

It will rewrite the /config/database.yml file. 
It will modify load.sh and reset.sh to access the docker database.

It also adds the gem "rubytheracer" to the gemfile.

Security - generate an ssh keypair, and add the public_key to the authorized_keys
file on the deployed antcat instance. 

The corresponding file id_rsa must be current and exist in this directory. It must be set 
`chmod 600`

to get a shell prompt (for debugging) run debug_export.sh.

A copy of the gzipped SQL file will be placed in ./database_archive.
The exported file will be in ./database_export.

To expose the generated file with a web interface, run "web_server_daemon.sh" from this directory.
Kill the server with web_server_daemon_stop.sh. Web servers must be run from this directory.

If you'd like the web server interactively (temporariliy, so ^c kills it naturally) 
run web_server_interactive.sh

url is http://<servername>:9090/antcat.antweb.txt
