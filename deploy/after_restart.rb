# coding: UTF-8
run "cd #{release_path}; bundle exec rake sunspot:solr:start; sleep 3; bundle exec rake sunspot:solr:reindex"
