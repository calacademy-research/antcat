# coding: UTF-8
run "cd #{release_path};rake sunspot:solr:start;sleep 3;rake sunspot:solr:reindex"
