module Importers::Hol::HolCommands
  if defined?(Rails) && (Rails.env == 'development')
    Rails.logger = Logger.new(STDOUT)
  end


  def reset_average
    @requests = 0
    @average = 0
    print_char 'r'
  end

  def approxRollingAverage (new_sample)
    if @requests.nil?
      reset_average
    end
    @requests = @requests + 1
    @average -= @average / @requests
    @average += new_sample / @requests
  end

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


  def run_hol_command command, no_parse=false
    url = "http://osuc.biosci.ohio-state.edu/hymDB/OJ_Break."+ command +"&callback=api"
    #puts ("========= QUERY: " + url)
    sleep 0.5
    print_char "="
    string = nil
    tries = 0

    start_time = Time.now
    begin
      status = Timeout::timeout(10) do
        timeout_string = Curl::Easy.perform(url).body_str
      end
    rescue Curl::Err::ConnectionFailedError, Curl::Err::TimeoutError, Timeout::Error
      Timeout::Error
      tries += 1
      unless status.nil?
        puts ("timeout status :"+ timeout_string.to_s + " " + status.to_s )
      end
      sleep 3
      retry if tries < 20

    end
    end_time = Time.now
    approxRollingAverage (end_time - start_time)

    retval = []
    unless string.nil?


      #string.force_encoding('UTF-8')
      string.delete!("\n")
      string.delete!("\r")
      string.delete!("\t")

      badness = "\u0002"
      string.delete! badness.encode('utf-8')

      string.gsub! /^api\((.*)\);$/, '\1'
      if no_parse
        retval = string
      else
        retval = JSON.parse(string, :quirks_mode => true)
      end

    end
    retval
  end

  def get_taxa_command command
    taxa = run_hol_command command
    taxa['taxa']
  end

  def get_taxon_literature tnuid
    #http://osuc.biosci.ohio-state.edu/OJ_Break/getTaxonLit?tnuid=30148&showSyns=Y&format=json&key=FBF57A9F7A666FC0E0430100007F0CDC
    pubs = run_hol_command "getTaxonLit?tnuid=" + tnuid.to_s + "&showSyns=Y"
    pubs['pubs']

  end


  def get_taxon_info_command tunid
    run_hol_command "getTaxonInfo?tnuid=" + tunid.to_s, true
  end



end