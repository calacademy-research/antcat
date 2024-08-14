Temporary README to explain how to run docker in this subdirectory.

setup: unzip the db initialization file sql-data/init.sql.gz.
	- it is too large for git to handle unless zipped
	- make sure not to commit this change when pushing
start: docker-compose up --build -d
	- d flag runs detached in background
	- build processes any changes in the Dockerfile
stop: docker-compose down -v
	- v flag removes volumes which is necessary when starting the next time
