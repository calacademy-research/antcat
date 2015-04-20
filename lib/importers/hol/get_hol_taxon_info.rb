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
    start_at = 3700
    hol_count = 0
    #for hol_hash in HolDatum.order(:name).where(taxon_id: nil, is_valid: 'Valid')
    #for hol_hash in HolDatum.order(:tnuid).where(is_valid: 'Valid')
    for hol_hash in HolDatum.order(:tnuid)

      # if hol_count > 5
      #   exit
      # end

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

  def match_protonym name, reference
    keep = nil

    unless reference.nil? || name.nil?
      protonyms = Protonym.where(name_id: name.id)
      #puts "name and reference: " + name.name + " " + reference.id.to_s
      protonyms.each do |protonym|
        citation = protonym.authorship
        unless citation.nil?
          cit_reference = citation.reference
          unless reference.nil? || cit_reference.nil?
            if reference.id == cit_reference.id
              unless keep.nil?
                puts "Two or more protonyms match reference: " +
                         reference.id.to_s +
                         " protonum 1:" +
                         keep.id.to_s +
                         " protonum 2:" +
                         protonym.id.to_s

                return nil

              end
              keep = protonym
            end
          end
        end
      end
    end

    keep

  end


  # iterates over the existing json blobs and populates selected columns
  # Links to antcat objects when and where possible. If those antcat columns
  # are already populated, it does not attempt the link.
  # "Citation" links take a long time and are currently hardcoded disabled.
  # We're also not getting any hits on "citation".
  def link_objects
    start_at = 0
    stop_after = 1000000
    hol_count = 0
    for hol_details in HolTaxonDatum.order(:tnuid)
      hol_count = hol_count +1
      if (hol_count < start_at)
        next
      end
      if hol_count > start_at + stop_after
        exit
      end
      print_char "."
      begin
        details_hash = JSON.parse hol_details.json
      rescue JSON::ParserError
        puts ("Fatal parse error for tnuid:" + hol_details.tnuid.to_s)
      end

      begin
        unless details_hash['rank']=='Species'
          # puts "not species"
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

      hol_details['year'] = get_year details_hash
      hol_details['start_page'] = get_start_page details_hash
      hol_details['end_page'] = get_end_page details_hash
      hol_details['journal_name'] = get_journal_name details_hash
      hol_details['hol_journal_id'] = get_hol_journal_id details_hash
      hol_details['rank'] = get_rank details_hash
      hol_details['rel_type'] = get_rel_type details_hash
      hol_details['status'] = get_status details_hash
      hol_details['fossil'] = get_fossil details_hash
      hol_details['valid_tnuid'] = get_valid_tnuid details_hash
      hol_details['name'] = get_name details_hash
      hol_details['is_valid'] = get_valid details_hash
      hol_details.save

      next


      if hol_details.antcat_author_id.nil?
        author = @author_matcher.get_antcat_author_name details_hash
        unless author.nil?
          hol_details['antcat_author_id'] = author.author_id
        end
        if hol_details['antcat_author_id'].nil?
          print_char 'A'
        else
          print_char 'a'
        end
      end


      protonym = nil
      reference = nil

      #
      # Journal
      #

      if hol_details.antcat_journal_id.nil?

        journal = @journal_matcher.get_antcat_journal hol_details['journal_name']
        unless journal.nil?
          hol_details['antcat_journal_id'] = journal.id
        end
        if hol_details['antcat_journal_id'].nil?
          print_char 'J'
        else
          print_char 'j'
        end
      end

      #
      # reference
      #
      if hol_details.antcat_reference_id.nil?
        reference = @reference_matcher.get_reference hol_details, details_hash, @journal_matcher
        if reference.nil?
          print_char 'R'
        else
          print_char 'r'
          hol_details['antcat_reference_id'] = reference.id
        end
      end

      #
      # taxon name
      #
      if hol_details.antcat_name_id.nil?
        name = @name_matcher.get_antcat_name_id hol_details, details_hash
        if name.nil?
          print_char 'N'
        else
          print_char 'n'
          hol_details['antcat_name_id'] = name.id
        end
      end


      #
      # protonym
      #
      if hol_details.antcat_protonym_id.nil? and !hol_details.antcat_reference_id.nil?
        if reference.nil?
          reference = Reference.find hol_details.antcat_reference_id
        end
        protonym = match_protonym name, reference
        if protonym.nil?
          print_char "P"
        else
          hol_details['antcat_protonym_id'] = protonym.id
          print_char "p"
        end
      end

      #
      # Citation
      #
      do_citations = false
      if do_citations and hol_details.antcat_citation_id.nil? and !hol_details.antcat_reference_id.nil?
        if reference.nil?
          reference = Reference.find hol_details.antcat_reference_id
        end

        #
        # for diagnosis only
        #
        diags = false
        # unless hol_details.antcat_protonym_id.nil?
        #   diags = true
        #   if protonym.nil?
        #     protonym = Protonym.find hol_details.antcat_protonym_id
        #   end
        #   puts ("Protonym citation id: "+ protonym.authorship.id.to_s)
        #
        # end

        #
        # End diagnosis
        #

        citation = @citation_matcher.get_antcat_citation_id reference, hol_details, details_hash, diags
        if citation.nil?
          print_char 'C'
        else
          hol_details['antcat_citation_id'] = citation.id
          print_char 'c'
        end


      end

      #
      # Taxon
      #
      taxon = nil
      if hol_details.antcat_taxon_id.nil? and !hol_details.antcat_protonym_id.nil?
        if protonym.nil?
          protonym = Protonym.find hol_details.antcat_protonym_id
        end
        unless protonym.nil?
          #puts ("Protonym citation id: "+ protonym.authorship.id.to_s)
          taxa = Taxon.where(protonym_id: protonym.id, name_id: name)
          if taxa.length == 1
            taxon = taxa[0]
            hol_details['antcat_taxon_id'] = taxon.id
            print_char 't'
          else
            if (taxa.length > 1)
              puts "No matching protonyms. Count: " + taxa.length.to_s
            end
            print_char 'T'
          end
        end
      end

      hol_details.save!

    end
  end

  def create_objects
    start_at = 2005
    stop_after = 2000
    hol_count = 0
    for hol_details in HolTaxonDatum.order(:tnuid)
      hol_count = hol_count +1
      if (hol_count < start_at)
        next
      end
      if hol_count > start_at + stop_after
        exit
      end
      print_char "."
      if hol_details.antcat_name_id.nil?

        print_char "*"
        create_new_name hol_details
      end

    end
  end


  # TODO:  author/year for honomyms. Check to see if we can create more reference (citation?) matches
  # by doing author/year

  #   Camponotus semicarinatus => Camponotus (Colobopsis) semicarinata status: Subsequent name/combination
  # genus (subgenus) species


  # we have 15911 objects with no name match but a reference, author, and journal match).
  #
  #     In this case, I will search all the synonyms and their statuses to see if we can
  # find any synonym with a valid antcat name. The very first pass will be to identify a HOL
  # synonym that is a valid antcat taxon that matches a taxon that HOL also thinks is valid.
  #  Create the taxa with the new name, mark it with a status that maps nicely to an antcat status,
  #   create a citation (I’ll search just in case we get lucky and get a match,
  # but I really have gotten zero..) and create the protonym.
  #
  # Prerequesite: Name is nil.
  def create_new_name hol_taxon
    puts
    tnuid = hol_taxon.tnuid
    # unless name_valid? hol_data.name
    #   return
    # end


    puts "#{hol_taxon.name}  status: #{hol_taxon.status} valid: #{hol_taxon.is_valid} rel_type: #{hol_taxon.rel_type} tnuid: '#{hol_taxon.tnuid}'"

    valid_hol_taxon = nil
    if (hol_taxon.is_valid.nil? or hol_taxon.is_valid.downcase != "valid")
      valid_hol_taxon_tnuid = hol_taxon.valid_tnuid
      if valid_hol_taxon_tnuid.nil?
        puts "valid tnuid entry missing"
      else
        valid_hol_taxon = HolTaxonDatum.find_by_tnuid valid_hol_taxon_tnuid

        puts "  VALID hol taxon: '#{valid_hol_taxon.name}'  status: '#{valid_hol_taxon.status}' "+
                 " valid: '#{valid_hol_taxon.is_valid}' rel_type: '#{valid_hol_taxon.rel_type}' "+
                 "antcat_taxon_id: '#{valid_hol_taxon.antcat_taxon_id}' tnuid: '#{valid_hol_taxon.tnuid}'"
      end
    end

    if valid_hol_taxon.antcat_taxon_id.nil?
      valid_hol_taxon.antcat_taxon_id = find_antcat_taxon valid_hol_taxon
    end


    for hol_synonym in HolSynonym.where(tnuid: tnuid)

      hol_taxon_synonym = HolTaxonDatum.find_by_tnuid hol_synonym.synonym_id

      unless hol_taxon_synonym.nil?
        synonym_tnuid = hol_taxon_synonym.tnuid
        # unless name_valid? hol_taxon_synonym.name
        #   next
        # end
        puts "  #{hol_taxon.name} => '#{hol_taxon_synonym.name}' status: '#{hol_taxon_synonym.status}' "+
                 "valid: '#{hol_taxon_synonym.is_valid}' taxon_id: #{hol_taxon_synonym.antcat_taxon_id}"+
                 " rel_type: '#{hol_taxon_synonym.rel_type}'  tnuid: '#{hol_taxon_synonym.tnuid}'"
      end
    end
  end

  # Takes an hol taxon and does any hierustics to match up with an antcat taxon
  # This is assuming we don't get a perfect across the board match from earlier work.

  # Start with a name search - if we can't match a name, then check if it's something very new?
  # If it's 2014 or later, create everything.

  # if we can match a name, check year and author name. If those match, check page numbers. If all of those match, we're golden

  def find_antcat_taxon valid_hol_taxon
    if valid_hol_taxon.antcat_name_id.nil?
      if valid_hol_taxon.year >= 2014
        puts "Hey, this might be new! I can't find the name, and it's 2014 or later!"
      end
    else
      #
      # We have a name, what's missing?
      #
      unless valid_hol_taxon.antcat_protonym_id.nil?
        puts "What the hell - we have a protonym and we can't figure this out?"
      end
      if valid_hol_taxon.antcat_journal_id.nil?
        # Aha, journal is missing. Let's patch that up.
        candidate_taxa = Taxon.where(name_id: valid_hol_taxon.antcat_name_id)
        candidate_taxa.each do |taxon|
          antcat_protonym = taxon.protonym
          citation = antcat_protonym.authorship
          reference = citation.reference
          score = 0
          booshite
          if reference.reference_author_names.first.author_name_id == valid_hol_taxon.antcat_author_id
            puts "Author match"
            score += 1
          end
          if reference.year == valid_hol_taxon.year
            puts "year match"
            score += 1
          end

          hol_start_page = valid_hol_taxon['start_page']
          hol_end_page = valid_hol_taxon['end_page']
          page_hash = get_page_from_string reference.pagination
          unless page_hash.nil?
            if page_in_range page_hash, hol_start_page, hol_end_page
              puts "page range match"
              score += 1
            end
          end
        end
      end
    end
  end


  # Identifies obsolete nomenclature
  def name_valid? name
    invalid_array = [" var. ", # "var." notation - alternate spelling?
                     " r. ",
                     " subsp. ",
                     " (",
                     " )",
                     " st. "
    ]

    invalid_array.each do |invalid_string|
      if name.include? invalid_string
        return false
      end
    end
    return true

  end


  # If we have found no name that matches this one,
  # then iterate over the hol_synonyms for this taxon.
  # for each tnuid in the synonym list, "expand" its record
  # (find the base objects), if it hasn't been done already
  #
  # Determine what this name is. Options:
  #  New valid combination that obsoletes an existing taxon
  #  A synonym for an existing valid taxon
  #   Create taxon entry
  #    Create
  #   Create protonym
  #   Create reference (if needed)
  #   Create antcat synonym information
  #  A valid combination of a previously non-existent taxon
  #   All new stuff, no synonym entries necessary.


  # def create_new_name hol_details, details_hash, taxon, reference, name, citation, protonym
  #   # Iterate over all the hol_synonyms. If we get a hit with an existing antcat-linked taxon,
  #   # then it's a synonym of said item. Create linkages.
  #
  #   # If we find no antcat linked taxa in the hol_synonyms, then we create this item (and its synonyms!)
  #   # from scratch. Use what we have from above.
  # end

  # hol status:
  # "Original name/combination"
  # "Subsequent name/combination"
  # "Justified emendation"
  # "Replacement name"
  # "Unavailable, literature misspelling"
  # "Junior homonym"
  # "Susequent name/combination"
  # "Subseqent name/combination"
  # "Unavailable, suppressed by ruling"
  # "Homonym & junior synonym"
  # "Unnecessary replacement name"
  # "Unavailable, incorrect original spelling"
  # Emendation
  # "Unjustified emendation"
  # "Common name"
  # "Unavailable, other"
  # "Unavailable, nomen nudum"
  # Misidentification

  # antcat status:
  # valid
  # unidentifiable
  # "excluded from Formicidae"
  # homonym
  # unavailable
  # synonym
  # "collective group name"
  # "obsolete combination"
  # "original combination"

  # hol "rel_type"
  # Member
  # Synonym
  # "Nomen nudum"
  # "Junior synonym"


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

  def get_valid_tnuid details_hash
    extract details_hash, ['valid_taxon', 'tnuid']

  end

  def get_name details_hash
    extract details_hash, ['name']
  end

  def get_valid details_hash
    extract details_hash, ['valid']
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




