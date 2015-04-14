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
class Importers::Hol::GetHolTaxonInfo < Importers::Hol::BaseUtils
  include HolCommands


  def initialize
    @print_char=0
    @journal_matcher = HolJournalMatcher.new
    @author_matcher = HolAuthorMatcher.new
    @reference_matcher = HolReferenceMatcher.new
    @name_matcher = HolNameMatcher.new
    @citation_matcher = HolCitationMatcher.new


  end

  def setup_tnuid_dictionary
    @tnuid_dictionary = {}
    for hol_data in HolTaxonDatum.all
      @tnuid_dictionary[hol_data.tnuid]=nil

    end
    puts "Done pre-loading tables"

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

        print_string hol_hash.tnuid.to_s

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

      family = get_family details_hash
      if family != "Formicidae"
        puts ("****** Deleting from family: " + family.to_s + " tnuid:" + hol_details.tnuid.to_s)
        #delete_hol hol_details.tnuid
        next
      end

      hol_details['antcat_author_id'] = @author_matcher.get_antcat_author_id details_hash
      if hol_details['antcat_author_id'].nil?
        print_char 'A'
      else
        print_char 'a'
      end

      hol_details['year'] = get_year details_hash
      hol_details['start_page'] = get_start_page details_hash
      hol_details['end_page'] = get_end_page details_hash
      hol_details['journal_name'] = get_journal_name details_hash
      hol_details['hol_journal_id'] = get_hol_journal_id details_hash
      hol_details['rank'] = get_rank details_hash
      hol_details['rel_type'] = get_rel_type details_hash
      hol_details['status'] = get_status details_hash
      hol_details['fossil'] = get_fossil details_hash



      if hol_details['hol_journal_id'].nil?
        print_char 'J'
      else
        print_char 'j'
      end
      hol_details['antcat_journal_id'] = @journal_matcher.get_antcat_journal_id hol_details['journal_name']
      reference = @reference_matcher.get_reference hol_details, details_hash, @journal_matcher
      if (reference.nil?)
        print_char 'R'
      else
        print_char 'r'
        hol_details['antcat_reference_id'] = reference
      end
      name = @name_matcher.get_antcat_name_id hol_details, details_hash
      if (name.nil?)
        print_char 'N'
      else
        print_char 'n'
        hol_details['antcat_name_id'] = name
      end
      citation = @citation_matcher.get_antcat_citation_id reference, hol_details, details_hash
      if(citation.nil?)
        print_char 'C'
      else
        hol_details['antcat_citation_id'] = citation
        print_char 'c'
      end
      # build synonyms?


      hol_details.save!


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
    extract details_hash, ['hier', "Family", "name"]
  end


  def get_status details_hash
      extract details_hash, ['status']
  end

  def get_rank details_hash
    extract details_hash, ['rank']
  end

  def get_rel_type details_hash
    extract details_hash, ['rel_type']
  end

  def get_fossil details_hash
    fossil = extract details_hash, ['fossil']

    unless fossil.nil?
      fossil = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(fossil)
    end
    fossil
  end


  def delete_hol tnuid
    HolDatum.destroy.where(tunid: tnuid)
    HolTaxonDatum.destroy.where(tunid: tnuid)
  end

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




