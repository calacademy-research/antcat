module Importers::Hol::HolCommands

  #HOL api: http://osuc.osu.edu/osucWiki/OJ_Break_API_Reference


  # First, search for the text string "Formicidae" as a taxon using getTaxaFromText
  # (http://osuc.biosci.ohio-state.edu/hymDB/OJ_Break.getTaxaFromText?name=Formicidae&limit=10&nameOnly=N&callback=api).
  #     This will result in two separate name uses: 1) Formicidae as a valid name for the family with a tnuid of 152; 2)
  #  Formicidae as an invalid usage of a concept equivalent to the modern subfamily of Formicinae with a tnuid of 238704.
  #  You want the first tnuid, 152. Using this tnuid, you can get some basic taxonomic information (rank, author,
  #  taxonomic hierarchy, original description reference, contributors to the resource for this taxon, etc.)
  #
  #
  #  with getTaxonInfo (http://osuc.biosci.ohio-state.edu/hymDB/OJ_Break.getTaxonInfo?tnuid=152&callback=api);
  #  synomyms with getTaxonSynonyms (http://osuc.biosci.ohio-state.edu/hymDB/OJ_Break.getTaxonSynonyms?tnuid=152&callback=api);
  #  or all included taxa with getIncludedTaxa
  #  (http://osuc.biosci.ohio-state.edu/hymDB/OJ_Break.getIncludedTaxa?tnuid=152&showSyns=N&callback=api).


  def run_hol_command command
    url = "http://osuc.biosci.ohio-state.edu/hymDB/OJ_Break."+ command +"&callback=api"
    #puts ("========= QUERY: " + url)
    sleep 1
    print "="
    string = nil
    tries = 0

    begin
      string = Curl::Easy.perform(url).body_str
    rescue Curl::Err::ConnectionFailedError, Curl::Err::TimeoutError
      retry if tries < 20
      tries += 1
      sleep 3
      print "$"
    end


    string.gsub! /^api\((.*)\);$/, '\1'
    retval = []
    unless string.nil?
      retval = JSON.parse string

    end
    retval
  end

  def get_taxa_command command
    taxa = run_hol_command command
    taxa['taxa']
  end
end