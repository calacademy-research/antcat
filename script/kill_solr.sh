SOLR_PID=$(ps aux | grep -v grep | grep 'solr.solr.home' | awk '{print $2}')

digits='^[0-9]+$'
if ! [[ $SOLR_PID =~ $digits ]]; then
  echo "solr is not running" >&2; exit 1
else
  echo "killing solr (pid $SOLR_PID)..."
  kill $SOLR_PID
fi
