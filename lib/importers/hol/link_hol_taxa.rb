class Importers::Hol::LinkHolTaxa < Importers::Hol::BaseUtils

  def initialize
    @name_matcher = HolNameMatcher.new

  end

  def create_bad_case
    hol_details = HolTaxonDatum.find_by_tnuid 361797
    create_objects_from_hol_taxon hol_details
  end

  def create_objects
    start_at = 60700
    stop_after = 1000000
    hol_count = 0
    for hol_details in HolTaxonDatum.order(:tnuid)
      #if hol_count % 20 == 0
      #end
      hol_count = hol_count +1
      if (hol_count < start_at)
        next
      end
      if hol_count > start_at + stop_after
        exit
      end
      #   print_char "."
      print_string(" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #{hol_count.to_s} \n")
      create_objects_from_hol_taxon hol_details
    end


  end


  #
  # Bug in select * from taxa where id = 474744
  # processing tnuid 17303 wrong.
  # It points to genus Neoponera (430115), which is the parent of the current valid genus
  # instead of genus Pachycondyla (430103) which is what corresponds to this name.
  #


  #
  #     In this case, I will search all the synonyms and their statuses to see if we can
  # find any synonym with a valid antcat name. The very first pass will be to identify a HOL
  # synonym that is a valid antcat taxon that matches a taxon that HOL also thinks is valid.
  #  Create the taxa with the new name, mark it with a status that maps nicely to an antcat status,
  #   create a citation (I’ll search just in case we get lucky and get a match,
  # but I really have gotten zero..) and create the protonym.
  #
  #
  #
  #
  def create_objects_from_hol_taxon hol_taxon
    puts


    # For many of these hol synonyms, we're looking to create an "obsolete combination"
    # of an existing valid taxa.
    # We need these obsolete combinations to point to the protonym of the valid taxa,
    # and to create synonym entries. If we can't locate the protonym of the valid taxa,
    # we're pretty much out of luck.
    #


    puts hol_string(hol_taxon)

    #
    # Get valid taxon
    #
    valid_hol_taxon = nil
    # If we're not starting from a valid taxa, then


    #  Add a note that we need to be checking the hol protonym for an antcat match, too,
    #  just in case we match that way.
    #  end
    # ", I expect many of the combinations in HOL will be found among the Taxt notes that Mark semi-parsed"
    valid_antcat_taxon = find_valid_antcat_taxon hol_taxon

    if valid_antcat_taxon.nil?
      puts "==== cannot locate valid antcat taxon for #{hol_taxon.name} tnuid: #{hol_taxon.tnuid}"
      return
    end
    create_taxon_synonym valid_antcat_taxon, hol_taxon
    for hol_synonym in HolSynonym.where(tnuid: hol_taxon.tnuid)
      hol_taxon_synonym = HolTaxonDatum.find_by_tnuid hol_synonym.synonym_id
      unless hol_taxon_synonym.nil?
        puts "  #{hol_taxon.name} => " + hol_string(hol_taxon_synonym)
        new_taxon = create_taxon_synonym valid_antcat_taxon, hol_taxon_synonym
        #abort("Take a look at taxon id: #{new_taxon.id}")

      end
    end
  end


  #
  # If it's missing, create an antcat name and return it.
  # If there's a pre-existing name that matches, return that.
  # Sets "nonconforming" flag as needed for displaying a literal string
  #
  def find_or_create_name hol_taxon_name_string, force_nonconforming = false
    # Make certain this doesn't already exist!


    lookup_name = @name_matcher.get_name_without_previous_genus hol_taxon_name_string
    name = Name.find_by_name lookup_name
    is_nonconforming = false
    if(force_nonconforming or hol_taxon_name_string.index("."))
      is_nonconforming = true
    end

    if name.nil? or name.nonconforming_name != is_nonconforming
      name = Name.parse lookup_name, true

      if name.nil?
        puts "Failed to parse name; fatal"
        return nil
      end
      name.auto_generated = true
      name.origin = 'hol'
      name.nonconforming_name = is_nonconforming

      name.save
      puts "     **** new name created: #{name.name} with id: #{name.id} and is nonconforming: #{is_nonconforming}  type: #{name.type}"
    end


    name
  end

  # start at hol_taxon. If there's a valid antcat id, get it's current_valid.
  # if there's no valid antcat id, get hol's valid, then go to above.
  #
  #    It's possible that hol says that a taxa is valid, and it points to a tnuid that
  # has a matching antcat taxon id, but that the antcat taxon id is pointing to a record that
  # antcat thinks is invalid. If that is the case, find the current valid species according to antcat
  # and make that the current valid.

  def find_valid_antcat_taxon hol_taxon
    # if we have a valid antcat taxon right away, use it, and get its current valid.

    valid_antcat_taxon = get_most_recent_antcat_taxon hol_taxon.antcat_taxon_id

    unless valid_antcat_taxon.nil?
      #puts "Got the most recent from the passed in hol taxon(#{hol_taxon.name}). Most recent is #{valid_antcat_taxon.name_cache}:#{valid_antcat_taxon.id}"

      return valid_antcat_taxon
    end

    # if not, let's get the "current valid" HOL object and see if THAT has an antcat taxon mapping.
    valid_hol_taxon = nil
    if hol_taxon.is_valid.nil? or hol_taxon.is_valid.downcase != "valid"
      valid_hol_taxon_tnuid = hol_taxon.valid_tnuid
      if valid_hol_taxon_tnuid.nil?
        puts "valid tnuid entry missing"
      else
        valid_hol_taxon = HolTaxonDatum.find_by_tnuid valid_hol_taxon_tnuid
        unless valid_antcat_taxon.nil?
          puts "  VALID " + hol_string(valid_hol_taxon)
        end
      end
    end
    if valid_hol_taxon.nil?
      print_string "N"
      return nil
    end


    valid_antcat_taxon = get_most_recent_antcat_taxon valid_hol_taxon.antcat_taxon_id
    unless valid_antcat_taxon.nil?
      #puts "Got the most recent from discovered valid hol taxon(#{valid_hol_taxon.name}). Most recent is #{valid_antcat_taxon.name_cache}:#{valid_antcat_taxon.id}"

      return valid_antcat_taxon
    end

    #
    # Comb through all hol synonyms to see if any of them have an
    # indicated antcat_taxon_id. Hol will include the protonym here.

    for hol_synonym in HolSynonym.where(tnuid: hol_taxon.tnuid)
      hol_taxon_synonym = HolTaxonDatum.find_by_tnuid hol_synonym.synonym_id
      unless hol_taxon_synonym.nil?
        if !hol_taxon_synonym.antcat_taxon_id.nil?
          valid_antcat_taxon = get_most_recent_antcat_taxon hol_taxon_synonym.antcat_taxon_id
          unless valid_antcat_taxon.nil?
            puts "Got the most recent from a synonym of the hol taxon(#{hol_taxon_synonym.name}). Most recent is #{valid_antcat_taxon.name_cache}:#{valid_antcat_taxon.id}"

            return valid_antcat_taxon
          end
        end
      end
    end


    # Can't match to a valid antcat object. For now, we abort and abandon
    # these names because they don't have antcat objects to support them.
    # Later, we'll want to create antcat objects for this case.
    if valid_hol_taxon.antcat_taxon_id.nil?
      print_string "T"
    end
    nil
  end

  # Given an antcat taxon id, return the most current antcat taxon.
  def get_most_recent_antcat_taxon antcat_taxon_id, history = nil
    if antcat_taxon_id.nil?
      return nil
    else
      if history.nil?
        history = {}
      end
      antcat_taxon = Taxon.find antcat_taxon_id
      valid_antcat_taxon = get_most_recent_from_antcat_object antcat_taxon
      #
      # Cycle detection
      #
      valid_count = 0
      valid = nil
      if history.has_key?(antcat_taxon_id)
        history.each do |taxon_path_id|
          cur_taxon = (Taxon.find taxon_path_id)[0]
          if cur_taxon.status.downcase == "valid"
            valid_count += 1
            valid = cur_taxon
          end
        end
        if 1 == valid_count
          return valid
        else
          return nil
        end
      end

      #   iterate over history and do a valid count (saving each valid hit)
      #   if the valid count is 1, return it
      #
      #     if the valid count is other, return nil
      # end
      # end
      # Self pointer; we're all set!
      if valid_antcat_taxon.id == antcat_taxon.id
        return valid_antcat_taxon
      end
      if valid_antcat_taxon.nil?
        return antcat_taxon
      end
      unless valid_antcat_taxon.current_valid_taxon.nil?
        # if valid_antcat_taxon.current_valid_taxon.nil?
        #   puts "End of the line. Most current valid according to antcat is #{valid_antcat_taxon.name_cache}."
        # end
        if valid_antcat_taxon.current_valid_taxon.id != valid_antcat_taxon.id
          history[antcat_taxon_id] = nil
          valid_antcat_taxon = get_most_recent_antcat_taxon valid_antcat_taxon, history
          if valid_antcat_taxon.nil?
            puts "Fatal - invalid pointer to most current valid taxon. Started at antcat id: #{antcat_taxon_id}"
            return antcat_taxon
          end
        end
      end

      return valid_antcat_taxon
    end
  end

  # returns taxon object referenced under "current valid taxon", or self if self is current valid.
  def get_most_recent_from_antcat_object antcat_taxon
    if antcat_taxon.nil?
      return nil
    else
      if antcat_taxon.current_valid_taxon
        return Taxon.find antcat_taxon.current_valid_taxon
      else
        return antcat_taxon
      end
    end
  end


  #
  # Given a hol entry, create a synonym (if necessary)
  # to the valid antcat taxon passed in, if possible.
  #
  def create_taxon_synonym valid_antcat_taxon, hol_taxon
    if valid_antcat_taxon.is_a? Numeric
      puts ("********* unknown error source - valid antcat taxon is #{valid_antcat_taxon} instead of an object")
      return nil
    end
    unless hol_taxon.antcat_taxon_id.nil?
      # If there is a valid antcat ID for this object, skip everything -
      # it's already part of our world
      #print_string "k"
      return Taxon.find hol_taxon.antcat_taxon_id
    end


    #
    # Not sure why, but this: " Crematogaster (Crematogaster) pythia " kind of thing happens
    # (previous and current genus are the same.) Probably some kind of artifact of automatically generating
    # these things.
    #
    previous_genus = @name_matcher.get_previous_genus_from_hash(hol_taxon)
    current_genus = @name_matcher.get_current_genus_from_hash(hol_taxon)
    if previous_genus and (previous_genus != current_genus)
      #
      # This isn't a name match fail, in other words.
      # This is a previous combination in a different genus.
      #
      full_previous_name = @name_matcher.get_full_previous_name_from_string hol_taxon.name
      full_current_name = @name_matcher.get_full_current_name_from_string hol_taxon.name

      #Create TWO objects with two different parents per below.
      puts "Breaking #{hol_taxon.name} into two: #{full_previous_name} and #{full_current_name}}"
      # for this case, we now need to match each of the two hol_taxa with their "new" names to existing antcat taxa, if they
      # exist. Copy the hash, re-run link objects


      # previous_genera = Genus.where(name_cache: previous_genus)
      #if  previous_genera.length == 1
      hol_taxon = update_hol_taxon hol_taxon, valid_antcat_taxon, full_previous_name
      unless hol_taxon.antcat_taxon_id
        begin
          create_taxon_details valid_antcat_taxon, hol_taxon, full_previous_name
        rescue => e
          puts "Failed to create taxon because 1: #{e.to_s}"
        end

      end
      # else
      #   puts "   XXX Failed to match genus #{previous_genus}. Count: #{previous_genera.length}. Won't create taxon #{full_previous_name}"
      # end

      hol_taxon = update_hol_taxon hol_taxon, valid_antcat_taxon, full_current_name
      unless hol_taxon.antcat_taxon_id
        begin
          create_taxon_details valid_antcat_taxon, hol_taxon, full_current_name
        rescue => e
          puts "Failed to create taxon because 2: #{e.to_s}"
        end
      end
    else
      begin
        create_taxon_details valid_antcat_taxon, hol_taxon, hol_taxon.name
      rescue => e
        puts "Failed to create taxon because 3: #{e.to_s}"
      end
    end

  end

  def update_hol_taxon hol_taxon, valid_antcat_taxon, new_name
    current_name_object = @name_matcher.get_antcat_name_from_string new_name
    unless current_name_object
      puts "Failed to look up new name: #{new_name}"
      return hol_taxon
    end
    if valid_antcat_taxon.protonym_id
      current_taxon_object = match_taxon valid_antcat_taxon.protonym_id, current_name_object.id
      if current_taxon_object
        hol_taxon.antcat_taxon_id = current_taxon_object.id
      else
        puts "Failed to find a taxon with protonym id: #{valid_antcat_taxon.protonym_id} and name id: #{current_name_object.id}"
      end
    else
      puts "taxon id: #{valid_antcat_taxon} has no protonym id? That shoudln't be possible."
    end
    hol_taxon.antcat_name_id = current_name_object
    puts "Updated hol taxon with new taxon id: #{hol_taxon.antcat_taxon_id}"
    hol_taxon
  end

  def match_taxon protonym_id, name_id
    taxa = Taxon.where(protonym_id: protonym_id, name_id: name_id)
    if taxa.length == 1
      taxon = taxa[0]
      puts "matched a taxon to taxon id#{taxon.id}"

      return taxon
    else
      puts "No taxon match found. length: #{taxa.length}"
      if taxa.length > 1
        taxa.each do |thing|
          puts ("      Got taxon id: #{thing.id}")
        end
      end
      return nil
    end
  end
                                    n

  # This >will< make a new taxon.
  # it MIGHT make a name id, if it needs one.
  # It will greate a new name and genus if the genus name doesn't match
  def create_taxon_details valid_antcat_taxon, hol_taxon, name_string, force_nonconforming = false
    rank = valid_antcat_taxon.rank
    parent = valid_antcat_taxon.parent
    force_nonconforming = false
    new_genus_parent = handle_genus valid_antcat_taxon, hol_taxon, name_string, rank, parent
    if new_genus_parent

      if  rank.downcase != "subspecies"
        parent = new_genus_parent
        puts " Looks like that was the interesting bad genus case."
      elsif rank.downcase == "subspecies"
        # This case get hit because the valid species is a subspecies, but we're a binomial,
        # so we picked out our genus out of our "binomial subspecies". e.g.: we're "foo bar"
        # and the valid subspecies is "foo bar baz". So the handle_genus routine says,
        # "Hey, you're marked as genus foo, and the valid parent is species foo bar, let's match you to
        # genus foo instead of species foo bar".
        puts " Binomial subspecies!"
      end
    end

    #puts "Parsing new name: #{hol_taxon.name} as type: #{valid_antcat_taxon.rank}"

    #
    # doing this even though we might have an antcat_name_id, because we could have split it
    # into previous and subsequent genera. Speed optimize to use the antcat_name_id if this is killing us.
    #
    name = find_or_create_name name_string, force_nonconforming
    if name.nil?
      puts "====== failed to create name, aborting"
      return nil
    end
    hol_taxon.antcat_name_id = name.id
    hol_taxon.save
    # create name!

    # Check here - if it claims to be a subspecies, but it's binomial,
    # that's going to be a strange case.
    # I can't make a subspecies be the child of a genus; object model goes blooie
    # But the display USUALLY shows genus/species. Create a custom display for this case
    # in the catalog viewer.
    create_taxon valid_antcat_taxon, hol_taxon, name, rank, parent, hol_taxon.status

  end

  # case to handle:
  # The genus of this species might not match the genus of the valid species. Handle that.
  # also, the genus of this species might not exist, so handle that too.
  #
  # if we're failing to match on the genus part of the name, we need to create a genus
  # as a misspelling or alternate usage. That genus would have the same protonym as the valid genus
  # implicitly passed as part of valid_antcat_taxon.
  #
  # Returns nil if this isn't necessary.
  #
  # Parent is the parent of the species in question. Aka: The genus we're replacing
  # with this one, if we have to create it.

  def handle_genus valid_antcat_taxon, hol_taxon, name_string, rank, parent
    # Extract the genus name
    unless match = name_string.match(/^([a-zA-Z]+)([ a-zA-Z.]*)/)
      puts ("%%%%%%%% failed to match on genus/species?!")
      return nil
    end
    genus_string = match[1]

    name=nil
    # How do we know if the genus is what's not matching? Do a search in genus for matching name?
    genera = Genus.where(name_cache: genus_string)
    if genera.count == 0
      puts "  No genus found - creating name and taxon record for new genus '#{genus_string}'"
      name = find_or_create_name genus_string
      #  find the hol record that conforms to a genus with this name. if it has an antcat_id, raise hell.
      # if not, get its status, and this new taxon we create should be mapped to this antcat id.
      if name.nil
        raise 'Failed to parse name'
      end
      new_genus = create_taxon parent, hol_taxon, name, parent.rank, parent.parent, hol_taxon.status
      puts "   Created new genus: #{new_genus.id} with status #{hol_taxon.status}"

      return new_genus
    elsif genera.count == 1
      puts ("   Good genus found: #{genus_string}")
      # Does it match the valid taxon genus?
      if valid_antcat_taxon.parent.name_cache != genus_string
        puts "We need to point at this name's genus #{genus_string}, not the valid name's parent genus: #{valid_antcat_taxon.parent.name_cache}"
        return genera[0]
      end
    else
      puts "    Multiple genera found - that's odd: #{genera.count}"
    end
    nil

  end


  # Creates taxon,synonym (and any logic therein, derived from hol_Taxon.status),
  # taxon state, change  Takes name object and parent.
  def create_taxon valid_antcat_taxon, hol_taxon, name, rank, parent, hol_status
    mother = TaxonMother.new

    new_taxon = mother.create_taxon Rank[rank], parent

    new_taxon.auto_generated = true
    new_taxon.origin = 'hol'
    # Todo: status could well be valid - handle?

    # hol statuses:
    # "Original name/combination"
    # "Justified emendation"
    # "Replacement name"
    # "Junior homonym"
    # "Homonym & junior synonym"
    # "Common name"


    ## "Susequent name/combination"
    ## "Subseqent name/combination"
    ## "Subsequent name/combination"
    ## "Unavailable, other"
    ## "Unavailable, nomen nudum"
    ## "Unavailable, suppressed by ruling"
    ## "Unnecessary replacement name"
    ## "Unavailable, incorrect original spelling"
    ## Emendation
    ## "Unjustified emendation"
    ## "Unavailable, literature misspelling"
    ## Misidentification

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


    status_map = {"Unavailable, literature misspelling" => ['unavailable misspelling', false],
                  "Unavailable, incorrect original spelling" => ['unavailable misspelling', false],
                  "Unavailable, other" => ['unavailable uncategorized', false],
                  "Unavailable, nomen nudum" => ['unavailable uncategorized', false],
                  "Susequent name/combination" => ['unavailable uncategorized', false],
                  "Subseqent name/combination" => ['unavailable uncategorized', false],
                  "Subsequent name/combination" => ['unavailable uncategorized', false],
                  "Original name/combination" => ['unavailable uncategorized', false],
                  "Unavailable, suppressed by ruling" => ['unavailable uncategorized', false],
                  "Unnecessary replacement name" => ['unavailable uncategorized', false],
                  "Unavailable, incorrect original spelling" => ['unavailable uncategorized', false],
                  "Emendation" => ['unavailable uncategorized', false],
                  "Misidentification" => ['unavailable uncategorized', false],
                  "Unjustified emendation" => ['unavailable uncategorized', false],
                  "Original name/combination" => ['unavailable uncategorized', false],
                  "Justified emendation" => ['unavailable uncategorized', false],
                  "Replacement name" => ['unavailable uncategorized', false],
                  "Junior homonym" => ['unavailable uncategorized', false],
                  "Homonym & junior synonym" => ['unavailable uncategorized', false],
                  "Common name" => ['unavailable uncategorized', false]
    }

    for key, value in status_map
      if !hol_status.index(key).nil?
        new_taxon.status = value[0]
        new_taxon.display = value[1]
        break
      end
    end
    if new_taxon.status.nil?
      puts "     ===================== Unknown status, aborting: #{hol_taxon.status}"
      return
    end


    new_taxon.current_valid_taxon_id = valid_antcat_taxon.id

    new_taxon.protonym_id = valid_antcat_taxon.protonym.id
    # new_taxon.fossil = valid_antcat_taxon.fossil
    new_taxon.name_cache = name.name
    new_taxon.name_id = name.id
    new_taxon.type = valid_antcat_taxon.type
    new_taxon.type_name_id=1

    does_exist = Taxon.where(auto_generated: new_taxon.auto_generated,
                             protonym_id: new_taxon.protonym_id,
                             name_id: new_taxon.name_id,
                             current_valid_taxon_id: new_taxon.current_valid_taxon_id)
    if does_exist.length >= 1
      puts "$$$$$$$$$$$$$$$$ This taxa #{new_taxon.name_cache} already exists, not creating."
      return does_exist[0]
    end


    taxon_state = TaxonState.new
    taxon_state.deleted = false
    taxon_state.review_state = :old
    new_taxon.taxon_state = taxon_state
    taxon_state.save

    change = Change.new
    change.change_type = :create
    change.save!

    new_taxon.save!
    # Junior synonym would be new_taxon.id
    # senior synonym would be valid_antcat_taxon.id
    if !new_taxon.status.index('synonym').nil?
      # puts "Created synonym!"
      synonym = Synonym.new
      synonym.junior_synonym = new_taxon
      synonym.auto_generated = true
      synonym.origin='hol'
      synonym.senior_synonym = valid_antcat_taxon
      synonym.save
    end

    taxon_state.taxon_id = new_taxon.id
    taxon_state.save
    change.user_changed_taxon_id = new_taxon.id
    change.save!
    new_taxon.touch_with_version
    puts "     **** new taxon created antcat_id:#{new_taxon.id} name: #{new_taxon.name_cache} status: "+
             "#{new_taxon.status} hol status: #{hol_taxon.status} type: #{new_taxon.type} rank: #{new_taxon.rank}"
    hol_taxon.antcat_taxon_id = new_taxon.id
    hol_taxon.save
    new_taxon
  end

  def remove_auto_generated
    auto_gen_taxa = Taxon.where(auto_generated: true, origin: 'hol')
    auto_gen_taxa.each do |doomed_taxa|
      Taxon.transaction do
        hol_taxon = HolTaxonDatum.find_by_antcat_taxon_id doomed_taxa.id
        hol_taxon.antcat_taxon_id = nil
        hol_taxon.save
        doomed_taxa.destroy!

        TaxonState.destroy_all(taxon_id: doomed_taxa.id)
        Version.destroy_all(item_type: 'Taxon', item_id: doomed_taxa.id)

      end
    end

    Name.where(auto_generated: true, origin: 'hol').each do |doomed_name|
      Name.transaction do
        hol_taxon = HolTaxonDatum.find_by_antcat_name_id doomed_name.id
        hol_taxon.antcat_name_id = nil
        hol_taxon.save
        doomed_name.destroy!
      end
    end
  end


  def remove_imported_data
    # delete all from hol_data
    # delete all from hol_literature_pages
    # delete all from hol_literatures
    # delete all from hol_synonyms
    # delete all from hol_taxon_data

  end


end
