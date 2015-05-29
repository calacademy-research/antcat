# coding: UTF-8
require 'json'


#
#  Steps 3,4 and 5
#
#  step 3 "get_json":  download all the json records and create initial rows in the hol_taxon_data
# table. Populates only tnuid and json records.
#
# Step 4 "link_objects": makes loads of objects and does errorless matching up to antcat_taxon_id.
# Populates most of the fields in this table

# step 5- "fuzzy_match_taxa_ Meant to be run after initial import; this step will match as many bits as it can
# to associate a hol taxa with an antcat taxa.

#
# TODO: When complete, dump the string maps for authors, pubs, etc.
# review and correct, and re-run.
#

#
# Import top level HOL taxa data based on names.
# Entry points are compare_with_antcat and  compare_subspecies.
#
class Importers::Hol::DownloadHolTaxaDetails < Importers::Hol::BaseUtils
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
    @tnuid_details_dictionary = {}
    for hol_taxon_data in HolTaxonDatum.all
      @tnuid_details_dictionary[hol_taxon_data.tnuid]=nil

    end


    puts "Done pre-loading tables"

  end

  def get_single_taxa
    if @tnuid_details_dictionary.nil?
      setup_tnuid_dictionary
    end

    # [138325,
    # 234153,
    # 243023,
    # 246594,
    # 249100,
    # 263419,
    # 266593,
    # 266768,
    # 280521,
    # 135659,
    # 136107,
    # 137481,
    # 138526,
    # 308507]
    fetch_array = [138325,
    243023,
    246594,
    249100,
    263419,
    266593,
    266768,
    280521,
    135659,
    136107,
    137481,
    138526,
    308507]

    fetch_array.each do |id|
      populate_hol_details id
    end


  end

  # runs and compares all genera known to antcat.
  # pulls the getTaxonInfo from hol and populates the json field with it
  def get_json
    if @tnuid_details_dictionary.nil?
      setup_tnuid_dictionary
    end
    start_at = 0
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
      if (@tnuid_details_dictionary.has_key?(tnuid))
        print_char '.'
        next
      end

      # puts hol_hash.name
      # puts tnuid
      # info = get_taxon_info_command hol_hash.tnuid
      populate_hol_details hol_hash.tnuid

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


  # Checks the "synonym" table for any unpopulated hol_detail records.
  # There will be gaps here; we pull the hol_details based on genera we know about.
  #  e have downloaded 60,000 records from HOL so far. That’s of 360,000 some odd that they have,
  # which includes everything. Obviously, we don’t want to do that - it would stuff our database with
  # junk and take forever to download. Also it would place a high load on HOL, especially if we want
  # to re-scrape to get more recent changes. So, here are the steps I took:

  # 1: Iterate over all genera in antcat, and ask HOL for the record for that genus and all its children

  # 3: Get the full details for all records requested in step 1 ( this takes 3 days)

  # 6: Ask for the synonyms of all records pulled in step 1.

  # Turns out (should have expected this!) that step one only returns VALID children
  # (though I know I saw many invalid records go over the wire, so I ’ m not sure what happened there).
  # I need:

  # 6.5: Get the full details for all synonyms that weren’t pulled in step 1

  # then re-run 7.
  #
  def get_hol_synonym_json
    if @tnuid_details_dictionary.nil?
      setup_tnuid_dictionary
    end
    start_at = 0
    hol_count = 0
    #for hol_hash in HolDatum.order(:name).where(taxon_id: nil, is_valid: 'Valid')
    #for hol_hash in HolDatum.order(:tnuid).where(is_valid: 'Valid')
    for hol_synonym in HolSynonym.order(:synonym_id)
      get_tnuid = hol_synonym
      # if hol_count > 5
      #   exit
      # end

      hol_count = hol_count +1
      if (hol_count < start_at)
        next
      end
      tnuid = hol_synonym.synonym_id
      if @tnuid_details_dictionary.has_key?(tnuid)
        print_char '.'
      else
        populate_hol_details tnuid
      end


      # puts hol_hash.name
      # puts tnuid
      # info = get_taxon_info_command hol_hash.tnuid

      if hol_count % 10 == 0
        print_string tnuid.to_s
      end
      if hol_count % 15 == 0
        print_string @average.to_s
      end
      if hol_count % 100 == 0
        reset_average
      end
    end
  end

  def populate_hol_details tnuid
    json = get_taxon_info_command tnuid
    HolTaxonDatum.transaction do
      begin
        HolTaxonDatum.create(json: json, tnuid: tnuid)
      rescue ActiveRecord::StatementInvalid => e
        puts "Failed to save tnuid: " + tnuid.to_s + " probably record too long: " + (json.bytesize()/1024).to_s + "+k"
        puts e.to_s
      end
      print_char 's'
      @tnuid_details_dictionary[tnuid] = nil
    end
  end


  def match_protonym name, reference
    keep = nil

    unless reference.nil? || name.nil?
      protonyms = Protonym.where(name_id: name.id)
      puts "name and reference: " + name.name + " " + reference.id.to_s
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


  def create_bad_case
    hol_details = HolTaxonDatum.find_by_tnuid 140626
    details_hash = JSON.parse hol_details.json
    link_object details_hash, hol_details
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
        next
      end

      link_object details_hash, hol_details
    end
  end

  def unlink_objects
    # Wipe out "matched" fields on hol_taxon_data
    HolTaxonDatum.all.each do |taxa|
      taxa.year = nil
      taxa.start_page = nil
      taxa.end_page = nil
      taxa.journal_name = nil
      taxa.hol_journal_id = nil
      taxa.rank = nil
      taxa.rel_type = nil
      taxa.status = nil
      taxa.fossil = nil
      taxa.valid_tnuid = nil
      taxa.name = nil
      taxa.is_valid = nil
      taxa.antcat_journal_id = nil
      taxa.antcat_author_id = nil
      taxa.antcat_reference_id = nil
      taxa.antcat_protonym_id = nil
      taxa.antcat_taxon_id = nil
      taxa.save
    end

  end


  def link_object details_hash, hol_details
    # unless details_hash['rank'].downcase=='species'
    #   # puts "not species"    (in hol, there is no 'subspecies')
    #
    #   next
    #
    # end


    family = get_family details_hash

    if family != "Formicidae"
      puts ("****** Deleting from family: " + family.to_s + " tnuid:" + hol_details.tnuid.to_s)
      #delete_hol hol_details.tnuid
      return
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
    # taxon name - no approximations allowed here!
    #
    if hol_details.antcat_name_id.nil?
      name = @name_matcher.get_antcat_name_id_from_hash details_hash
      # puts "About to link name: #{name}"
      if name.nil?
        print_char 'N'
      else
        print_char 'n'
        hol_details['antcat_name_id'] = name.id
      end

    end

    #
    # No name match, but we do identify a previous genus
    # Hol is using non-standard notation genus (previous genus) species
    #
    # This is where we would add elements to the history - we're matching on a name.
    # if we match on all the other stuff
    #
    # never hit this case for genus, As expected.

    if hol_details.antcat_name_id.nil? and @name_matcher.get_previous_genus_from_hash details_hash
      full_name = details_hash['name']
      stripped_name = @name_matcher.get_name_without_previous_genus full_name
      name = @name_matcher.get_antcat_name_from_string stripped_name
      # puts "Matching on stripped name: #{name.name} with subgenus #{@name_matcher.get_previous_genus_from_hash(details_hash)}"
      # puts "Aborting - not doing this case for now."
      unless name.nil?
        print_char '@'
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
    # Taxon - this only works if we have a protonym, which requires a reference.
    #  in other words, >everything< matches.
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

  def test_single_taxon
    # child =361797
    # parent (should match) = 152080
    hol_taxon = HolTaxonDatum.find_by_tnuid 140626
    match_taxon hol_taxon
  end

  #
  # Meant to be run after initial import; this step will match as many bits as it can
  # to associate a hol taxa with an antcat taxa.
  #
  # Only runs if there's nil for antcaon_taxon_id.
  #
  def fuzzy_match_taxa
    start_at = 0
    stop_after = 200000000
    hol_count = 0
    for hol_taxon in HolTaxonDatum.order(:tnuid)
      if hol_count % 200 == 0
        print_string(" #{hol_count.to_s} ")
      end
      hol_count = hol_count +1
      if (hol_count < start_at)
        next
      end
      if hol_count > start_at + stop_after
        exit
      end
      match_taxon hol_taxon

    end
  end

  def match_taxon hol_taxon
    unless hol_taxon['rank']=='Species' or   hol_taxon['rank']=='Subspecies'
      return
    end
    if hol_taxon.antcat_taxon_id.nil?

      hol_taxon.antcat_taxon_id = match_antcat_taxon hol_taxon
      if hol_taxon.antcat_taxon_id.nil?
        print_char "V"
      else
        print_char "v"
        hol_taxon.save
        return
      end
    else
      print_char "."
    end
  end


  # Takes an hol taxon and does any hierustics to match up with an antcat taxon
  # This is assuming we don't get a perfect across the board match from earlier work.

  # Start with a name search - if we can't match a name, then check if it's something very new?
  # If it's 2014 or later, create everything.

  # if we can match a name, check year and author name. If those match, check page numbers. If all of those match, we're golden

  def match_antcat_taxon valid_hol_taxon
    puts "Starting to try to match: " + valid_hol_taxon.name
    if valid_hol_taxon.antcat_name_id.nil?
      if !valid_hol_taxon.year.nil? and valid_hol_taxon.year >= 2014
        puts "Hey, this might be new! I can't find the name, and it's 2014 or later!"
      else
        puts "no name match"
        return nil
      end
    end


    #
    # We have a name, what's missing?
    #
    unless valid_hol_taxon.antcat_protonym_id.nil?
      puts "What the hell - we have a protonym and we can't figure this out?"
    end
    @antcat_reference=nil
    if valid_hol_taxon.antcat_reference_id
      puts "We have a full reference.. that includes year, page range, and author."
      @antcat_reference = Reference.find valid_hol_taxon.antcat_reference_id

    else
      puts "No reference listed."
    end



    candidate_taxa = Taxon.where(name_id: valid_hol_taxon.antcat_name_id)
    puts "Checking #{candidate_taxa.length} taxa for matches"


    candidate_taxa.each do |taxon|
      taxon_id = check_taxon @antcat_reference, valid_hol_taxon, taxon

      # Check antcat synonyms
      if taxon_id.nil?
        taxon.junior_synonyms.each do |synonym|
           puts "Checking synonym as junior_synonyms #{synonym.name_cache}"

          taxon_id = check_taxon @antcat_reference, valid_hol_taxon, synonym
        end
      end
      if taxon_id.nil?
        taxon.senior_synonyms.each do |synonym|
           puts "Checking synonym as senior_synonyms #{synonym.name_cache}"
          taxon_id = check_taxon @antcat_reference, valid_hol_taxon, synonym
        end
      end
      unless taxon_id.nil?
        return taxon_id
      end
    end

     puts ("=============== match failed")
    nil
  end

  #
  # Does this reference match this hol_taxon?
  # Todo: we don't need to pass "taxon" here.
  #
  def check_taxon antcat_reference, valid_hol_taxon, taxon

    antcat_protonym = taxon.protonym
    citation = antcat_protonym.authorship
    reference = citation.reference

    if !antcat_reference.nil? and antcat_reference.id == reference.id
      #puts "References and name match - it's antcat taxon " + taxon.id.to_s
      return taxon.id
    end

    first_author_name = reference.reference_author_names.first
    if !first_author_name.nil? and first_author_name.author_name.author_id ==
        valid_hol_taxon.antcat_author_id
      #puts "Author match"
    else
      # puts "author mismatch - antcat: #{reference.reference_author_names.first.author_name.author_id} vs #{valid_hol_taxon.antcat_author_id}"
      return nil
    end

    if reference.year == valid_hol_taxon.year
      #puts "year match"
    else
      # puts "year mismatch antcat: #{reference.year} vs #{valid_hol_taxon.year}"
      return nil

    end


    hol_start_page = valid_hol_taxon['start_page']
    hol_end_page = valid_hol_taxon['end_page']
    page_hash = get_page_from_string citation.pages

    unless page_hash.nil?
      start_page = page_hash[:start_page]
      end_page = page_hash[:end_page]
      if page_in_range hol_start_page, hol_end_page, start_page, end_page
        #puts "page range match"
        # puts "Good match, no reference to antcat id #{taxon.id}"
        return taxon.id
      else
        # puts "pages mismatch"
        return nil
      end
    end

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
  # "Justified emendation"
  # "Replacement name"
  # "Unavailable, literature misspelling"
  # "Junior homonym"
  # "Susequent name/combination"
  # "Subseqent name/combination"
  # "Subsequent name/combination"

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

#
# # {
# "code":100,
#     "message":"API resource successfully retrieved",
#     "data":{
#     "id":"36809",
#     "tnuid":36809,
#     "name":"Technomyrmex elatior",
#     "taxon":"Technomyrmex elatior",
#     "author":"Forel",
#     "status":"Subsequent name/combination",
#     "rank":"Species",
#     "valid":"Valid",
#     "fossil":"N",
#     "rel_type":"Member",
#     "source":{
#     "id":"",
#     "name":"",
#     "logo":"",
#     "query":"",
#     "url":""
# },
#     "parent_taxon":{
#     "id":"2485",
#     "tnuid":2485,
#     "taxon":"Technomyrmex",
#     "author":"Mayr"
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
#     "name":"Dolichoderinae",
#     "taxon":"Dolichoderinae",
#     "author":"Forel",
#     "id":"2250",
#     "tnuid":2250,
#     "next":"Tribe"
# },
#     "Tribe":{
#     "name":"Tapinomini",
#     "taxon":"Tapinomini",
#     "author":"Emery",
#     "id":"239613",
#     "tnuid":239613,
#     "next":"Genus"
# },
#     "Genus":{
#     "name":"Technomyrmex",
#     "taxon":"Technomyrmex",
#     "author":"Mayr",
#     "id":"2485",
#     "tnuid":2485,
#     "next":"Species"
# },
#     "Species":{
#     "name":"Technomyrmex elatior",
#     "taxon":"Technomyrmex elatior",
#     "author":"Forel",
#     "id":"36809",
#     "tnuid":36809,
#     "next":"null"
# }
# },
#     "orig_desc":{
#     "url":"antbase.org/ants/publications/3984/3984.pdf",
#     "filesize":"723k",
#     "pages":[
#     {
#         "page_num":"284",
#     "page_url":"antbase.org/ants/publications/3984/3984_0284.pdf"
# },
#     {
#         "page_num":"285",
#     "page_url":"antbase.org/ants/publications/3984/3984_0285.pdf"
# },
#     {
#         "page_num":"286",
#     "page_url":"antbase.org/ants/publications/3984/3984_0286.pdf"
# },
#     {
#         "page_num":"287",
#     "page_url":"antbase.org/ants/publications/3984/3984_0287.pdf"
# },
#     {
#         "page_num":"288",
#     "page_url":"antbase.org/ants/publications/3984/3984_0288.pdf"
# },
#     {
#         "page_num":"289",
#     "page_url":"antbase.org/ants/publications/3984/3984_0289.pdf"
# },
#     {
#         "page_num":"290",
#     "page_url":"antbase.org/ants/publications/3984/3984_0290.pdf"
# },
#     {
#         "page_num":"291",
#     "page_url":"antbase.org/ants/publications/3984/3984_0291.pdf"
# },
#     {
#         "page_num":"292",
#     "page_url":"antbase.org/ants/publications/3984/3984_0292.pdf"
# },
#     {
#         "page_num":"293",
#     "page_url":"antbase.org/ants/publications/3984/3984_0293.pdf"
# },
#     {
#         "page_num":"294",
#     "page_url":"antbase.org/ants/publications/3984/3984_0294.pdf"
# },
#     {
#         "page_num":"295",
#     "page_url":"antbase.org/ants/publications/3984/3984_0295.pdf"
# },
#     {
#         "page_num":"296",
#     "page_url":"antbase.org/ants/publications/3984/3984_0296.pdf"
# }
# ],
#     "public":"Y",
#     "date":"1902",
#     "year":"1902",
#     "month":"01",
#     "type":"article",
#     "title":"Variétés myrmécologiques.",
#     "journal":"Annales de la Société Entomologique de Belgique",
#     "jrnl_id":1025,
#     "journal_id":"1025",
#     "series":"",
#     "volume":"46",
#     "vol_num":"",
#     "start_page":"284",
#     "end_page":"296",
#     "author_base_id":1005,
#     "author":"Forel",
#     "author_extended":[
#     {
#         "last_name":"Forel",
#     "initials":"A.",
#     "generation":"",
#     "name_order":"W",
#     "author_id":1005
# }
# ],
#     "doi":"10.5281/ZENODO.14504",
#     "pub_id":3984
# },
#     "trash":"",
#     "contribs":[
#     {
#         "contrib_id":2279,
#     "last_name":"Agosti",
#     "initials":"D.",
#     "name":"Donat Agosti",
#     "contrib_types":{
#     "taxon":"N",
#     "literature":"Y",
#     "occurrence":"N",
#     "media":"N"
# }
# },
#     {
#         "contrib_id":7748,
#     "last_name":"Cora",
#     "initials":"J. R.",
#     "name":"Joseph R. Cora",
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
#     "rank_value":3,
#     "num_records":0,
#     "num_spms":0,
#     "child_nums":[
#     {
#         "rank":"Subspecies",
#     "num":0
# }
# ]
# }
# }
# }
#
#
#
#
