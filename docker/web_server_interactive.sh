#!/usr/bin/env bash
cd ../database_export
docker run -it --rm --name web -p 8080:80 -v $(PWD):/usr/local/apache2/htdocs/ httpd:2.4
