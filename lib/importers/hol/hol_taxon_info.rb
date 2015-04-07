# coding: UTF-8
require 'json'



#
# TODO: When complete, dump the string maps for authors, pubs, etc.
# review and correct, and re-run.
#

#
# Import top level HOL taxa data based on names.
# Entry points are compare_with_antcat and  compare_subspecies.
#
class Importers::Hol::HolTaxonInfo < Importers::Hol::BaseUtils
  include HolCommands


  def initialize
    @print_char=0
    @tnuid_dictionary={}
    @journal_matcher = JournalMatcher.new
    @author_matcher = AuthorMatcher.new



  end

  def setup_tnuid_dictionary
    for hol_data in HolTaxonDatum.all
      @tnuid_dictionary[hol_data.tnuid]=nil
      puts "Done pre-loading tables"

    end
  end




  # runs and compares all genera known to antcat.
  # pulls the getTaxonInfo from hol and populates the json field with it
  def get_json
    if @tnuid_dictionary.nil?
      setup_tnuid_dictionary
    end
    start_at = 0
    hol_count = 0
    #for hol_hash in HolDatum.order(:name).where(taxon_id: nil, is_valid: 'Valid')
    #for hol_hash in HolDatum.order(:tnuid).where(is_valid: 'Valid')
    for hol_hash in HolDatum.order(:tnuid)

      #if hol_count > 100000
      #exit
      #end

      hol_count = hol_count +1
      if (hol_count < start_at)
        next
      end
      tnuid = hol_hash.tnuid
      if (@tnuid_dictionary.has_key?(tnuid))
        print_char '.'
        next
      end

      # puts hol_hash.name
      # puts tnuid
      # info = get_taxon_info_command hol_hash.tnuid
      json = get_taxon_info_command hol_hash.tnuid
      HolTaxonDatum.transaction do
        begin
          HolTaxonDatum.create(json: json, tnuid: tnuid)
        rescue ActiveRecord::StatementInvalid => e
          puts "Failed to save tnuid: " + tnuid.to_s + " probably record too long: " + (json.bytesize()/1024).to_s + "+k"
          puts e.to_s
        end

        print_char 's'

        @tnuid_dictionary[tnuid] = nil
      end
      if hol_count % 10 == 0

        print_string hol_count.to_s

      end
      if hol_count % 15 == 0
        print_string @average.to_s

      end
      if hol_count % 100 == 0
        reset_average
      end
    end
  end

  # iterates over the existing json blobs and populates selected columns
  def expand_json
    for hol_details in HolTaxonDatum.order(:tnuid)
      begin
        details_hash = JSON.parse hol_details.json
      rescue JSON::ParserError
        puts ("Fatal parse error for tnuid:" + hol_details.tnuid.to_s)
      end

      begin
        unless details_hash['rank']=='Species'
          next
        end
      rescue TypeError => e
        puts "Failed to parse record " + hol_details.tnuid.to_s + " json: " + hol_details.json
      end

      if get_family hol_details != "Formicidae"
        delete_hol hol_details.tnuid
      end

      hol_details['antcat_author_id'] = @author_matcher.get_antcat_author_id details_hash
      hol_details['year'] = get_year details_hash
      hol_details['year'] = get_year details_hash
      hol_details['start_page'] = get_start_page details_hash
      hol_details['end_page'] = get_end_page details_hash
      hol_details['journal_name'] = get_journal_name details_hash
      hol_details['hol_journal_id'] = get_hol_journal_id details_hash
      hol_details['antcat_journal_id'] = @journal_matcher.get_antcat_journal_id hol_details['journal_name']

      # todo: look up name_id
      # protonym has name_id
      # protonyum -> citation (via 'authorship')
      # citation has pages
      # citation -> reference
      # reference has year
      # reference has journal id
      # reference has publisher id

      # User.where(name: 'David', occupation: 'Code Artist').order('created_at DESC')
      # Protonym.where(authorship_id: hol_details.antcat_author_id, )
      hol_details.save!

      # unless hol_details.antcat_author_id.nil?
      #   hol_details.save!
      # end
    end
  end





  def get_hol_journal_id details_hash
    extract details_hash, ["orig_desc", "journal_id"]
  end

  def get_journal_name details_hash
    extract details_hash, ["orig_desc", "journal"]
  end



  def get_year details_hash
    year = extract details_hash, ["orig_desc", "year"]
    unless year.nil?
      year = year.to_i
    end
    year
  end

  def get_start_page details_hash
    start_page = extract details_hash, ["orig_desc", "start_page"]
    unless start_page.nil?
      start_page = start_page.to_i
    end
    start_page
  end

  def get_end_page details_hash
    end_page = extract details_hash, ["orig_desc", "end_page"]
    unless end_page.nil?
      end_page = end_page.to_i
    end
    end_page
  end

  def get_family details_hash
    extract details_hash, ['hier',"Family", "name"]
  end

  def delete_hol




end


# api({
#         "id":"146777",
#     "tnuid":146777,
#     "name":"Acalama",
#     "taxon":"Acalama",
#     "author":"Smith",
#     "status":"Original name/combination",
#     "rank":"Genus",
#     "valid":"Invalid",
#     "fossil":"N",
#     "rel_type":"Junior synonym",
#     "source":{
#     "id":"",
#     "name":"",
#     "logo":"",
#     "query":"",
#     "url":""
# },
#     "valid_taxon":{
#     "id":"146964",
#     "tnuid":146964,
#     "taxon":"Gauromyrmex",
#     "author":"Menozzi"
# },
#     "parent_taxon":{
#     "id":"146964",
#     "tnuid":146964,
#     "taxon":"Gauromyrmex",
#     "author":"Menozzi"
# },
#     "hier":{
#     "Kingdom":{
#     "name":"Animalia",
#     "taxon":"Animalia",
#     "author":"",
#     "id":"15158",
#     "tnuid":15158,
#     "next":"Phylum"
# },
#     "Phylum":{
#     "name":"Arthropoda",
#     "taxon":"Arthropoda",
#     "author":"",
#     "id":"15157",
#     "tnuid":15157,
#     "next":"Class"
# },
#     "Class":{
#     "name":"Hexapoda",
#     "taxon":"Hexapoda",
#     "author":"",
#     "id":"1",
#     "tnuid":1,
#     "next":"Order"
# },
#     "Order":{
#     "name":"Hymenoptera",
#     "taxon":"Hymenoptera",
#     "author":"",
#     "id":"52",
#     "tnuid":52,
#     "next":"Superfamily"
# },
#     "Superfamily":{
#     "name":"Vespoidea",
#     "taxon":"Vespoidea",
#     "author":"",
#     "id":"69",
#     "tnuid":69,
#     "next":"Family"
# },
#     "Family":{
#     "name":"Formicidae",
#     "taxon":"Formicidae",
#     "author":"Latreille",
#     "id":"152",
#     "tnuid":152,
#     "next":"Subfamily"
# },
#     "Subfamily":{
#     "name":"Myrmicinae",
#     "taxon":"Myrmicinae",
#     "author":"Lepeletier",
#     "id":"2258",
#     "tnuid":2258,
#     "next":"Tribe"
# },
#     "Tribe":{
#     "name":"Crematogastrini",
#     "taxon":"Crematogastrini",
#     "author":"Forel",
#     "id":"2278",
#     "tnuid":2278,
#     "next":"Genus"
# },
#     "Genus":{
#     "name":"Gauromyrmex",
#     "taxon":"Gauromyrmex",
#     "author":"Menozzi",
#     "id":"146964",
#     "tnuid":146964,
#     "next":"null"
# }
# },
#     "orig_desc":{
#     "url":"antbase.org/ants/publications/2668/2668.pdf",
#     "filesize":"155k",
#     "pages":[
#     {
#         "page_num":"205",
#     "page_url":"antbase.org/ants/publications/2668/2668_0205.pdf"
# },
#     {
#         "page_num":"206",
#     "page_url":"antbase.org/ants/publications/2668/2668_0206.pdf"
# },
#     {
#         "page_num":"207",
#     "page_url":"antbase.org/ants/publications/2668/2668_0207.pdf"
# },
#     {
#         "page_num":"208",
#     "page_url":"antbase.org/ants/publications/2668/2668_0208.pdf"
# }
# ],
#     "public":"N",
#     "date":"1949",
#     "year":"1949",
#     "month":"11",
#     "type":"article",
#     "title":"A new genus and species of ant from India (Hymenoptera: Formicidae).",
#     "journal":"Journal of the New York Entomological Society",
#     "jrnl_id":23,
#     "journal_id":"23",
#     "series":"",
#     "volume":"56",
#     "vol_num":"",
#     "start_page":"205",
#     "end_page":"208",
#     "author_base_id":1703,
#     "author":"Smith",
#     "author_extended":[
#     {
#         "last_name":"Smith",
#     "initials":"M. R.",
#     "generation":"",
#     "name_order":"W",
#     "author_id":1703
# }
# ],
#     "doi":"",
#     "pub_id":2668
# },
#     "type_species":{
#     "id":"145497",
#     "taxon":"Acalama donisthorpei",
#     "author":"Smith"
# },
#     "trash":"",
#     "contribs":[
#     {
#         "contrib_id":565,
#     "last_name":"Musetti",
#     "initials":"L.",
#     "name":"Luciana Musetti",
#     "contrib_types":{
#     "taxon":"N",
#     "literature":"Y",
#     "occurrence":"N",
#     "media":"N"
# }
# },
#     {
#         "contrib_id":2,
#     "last_name":"Johnson",
#     "initials":"N. F.",
#     "name":"Norman F. Johnson",
#     "contrib_types":{
#     "taxon":"Y",
#     "literature":"Y",
#     "occurrence":"N",
#     "media":"N"
# }
# }
# ],
#     "common_names":[
#
# ],
#     "stats":{
#     "rank_value":4,
#     "num_spms":0,
#     "child_nums":[
#     {
#         "rank":"Species",
#     "num":0
# },
#     {
#         "rank":"Subspecies",
#     "num":0
# }
# ]
# }
# });




