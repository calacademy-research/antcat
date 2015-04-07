# coding: UTF-8


#
# Import top level HOL taxa data based on names.
# Entry points are compare_with_antcat and  compare_subspecies.
#
class Importers::Hol::Catalog
  include HolCommands

  def initialize
    @print_char=0
    @hol_dictionary = {}
    @tnuid_dictionary={}
    @antcat_taxa_dictionary={}
    for hol_data in HolDatum.all
      @tnuid_dictionary[hol_data.tnuid]=nil
    end
    for taxon in Taxon.all
      if @antcat_taxa_dictionary[taxon.name_cache.downcase].nil?
        @antcat_taxa_dictionary[taxon.name_cache.downcase]=[]
      end
      @antcat_taxa_dictionary[taxon.name_cache.downcase].concat [taxon.id]
    end
    puts "Done pre-loading tables"
  end


  # runs and compares all genera known to antcat.
  def compare_with_antcat
    #HolDatum.delete_all

    #genus = Genus.find_by_name 'Bilobomyrma'
    genus_count = 0
    for genus in Genus.order(:name_cache).all
      if (genus_count >= 0)
        antcat_species = genus.species
        get_hol_species genus.name.to_s, genus_count
        compare_hol_and_antcat_species antcat_species, genus
      end
      if genus_count > 10000
        exit
      end

      genus_count = genus_count +1
    end
  end

  def add_to_hol_dict hol_hash
    if @hol_dictionary[hol_hash['name'].downcase].nil?
      @hol_dictionary[hol_hash['name'].downcase] = []
    end
    ary = @hol_dictionary[hol_hash['name'].downcase]
    ary.concat [hol_hash]
  end




  # runs and compares all TAXON TYPE (hardocded), one at a time
  # pull all *foo* by name and compare them
  def compare_subspecies
    subspecies_count=0
    for subspecies in Tribe.order(:name_cache).all
      if (subspecies_count >= 0)
       check_and_save_hol_for_taxon subspecies
      end
      if subspecies_count > 10000
        exit
      end
      if subspecies_count % 20 == 0
        print " " + subspecies_count.to_s + " "
        @print_char = @print_char + 2 + subspecies_count.to_s.length
      end
      subspecies_count = subspecies_count +1
    end
  end





  #
  # returns all taxa for a given genus. includes the genus
  #
  def get_hol_species genus, count
    puts
    puts ("=============================== " + genus.to_s + ":" + count.to_s + " ===============================")
    #hash = run_hol_command "getTaxaFromText?name=#{genus}&limit=10&nameOnly=N"
    @print_char = @print_char +1
    hash = run_hol_command "getTaxaFromText?name=#{genus}&limit=10&nameOnly=N"

    return [] if hash['taxa'].empty?

    hash['taxa'].each do |genus_hash|
      add_to_hol_dict genus_hash
      @print_char = @print_char +1

      genus_members_hash = run_hol_command "getIncludedTaxa?tnuid=#{genus_hash['tnuid']}&showSyns=Y&showFossils=Y&show_num_spms=Y"
      #puts "Got " + genus_members_hash.count.to_s + " HOL results."
      genus_members_hash['includedTaxa'].each do |includedTaxa|
        #print includedTaxa['name'] + ", "
        unless @tnuid_dictionary.has_key?(includedTaxa['tnuid'])
          add_to_hol_dict includedTaxa
          print_char "!"
        else
          print_char "d"
        end
      end
    end

  end


  def create_hol_datum_from_hash(hol_species)
    hd = HolDatum.new
    hd.tnuid = hol_species['tnuid']
    hd.tnid = hol_species['tnid']
    hd.name = hol_species['name']
    hd.taxon = hol_species['taxon']
    hd.author = hol_species['author']
    hd.rank = hol_species['rank']
    hd.status = hol_species['status']
    hd.is_valid = hol_species['valid']
    hd.lsid = hol_species['lsid']
    hd.many_antcat_references = hol_species['many_antcat_references']
    unless hol_species['fossil'].nil?
      if hol_species['fossil'].downcase == 'n'
        hd.fossil = false
      else
        hd.fossil = true
      end
    end
    hd.num_spms = hol_species['num_spms'].to_i
    hd
  end

  # Look up taxon id in hol_data. if we match on taxon.name_cache vs and taxon.id
  def check_existing_hol_for_taxon(taxon)
    hd = HolDatum.find_by_taxon_id(taxon.id)
    if !hd.nil? && hd.name = taxon.name_cache
      print_char ";"
      return true
    end
    false
  end

  # Go back to hol and ask about this particular taxon name.
  def check_and_save_hol_for_taxon(taxon)
    # It might already exist in the hol_data; do a lookup.
    if check_existing_hol_for_taxon(taxon)
      return
    end

    query_string = CGI::escape taxon.name_cache
    hol_taxa_hash = get_taxa_command "getTaxaFromText?name=#{query_string}&limit=10&nameOnly=N"
    if hol_taxa_hash.count > 1
      #puts ("Did a HOL query on " + taxon.name_cache + " and got more than one. Aborting.")
      print_char "~"
    end
    if hol_taxa_hash.count == 0
      print_char "X"
      return nil
    end
    hol_taxa_hash.each do |hol_hash|
      save_hol_data hol_hash, taxon.id
    end

  end



  def save_hol_data hol_hash, taxon_id
    if  @tnuid_dictionary.has_key?(hol_hash['tnuid'])
      print_char ","
      return
    end
    hd = create_hol_datum_from_hash(hol_hash)
    hd.taxon_id = taxon_id


    records = nil
    begin
      records = HolDatum.find_by_tnuid hd['tnuid']
    rescue ActiveRecord::RecordNotFound => e

    end
    if records.nil?
      #get_additional_hol_taxon_info hol_hash
      hd.save
      @tnuid_dictionary[hol_hash['tnuid']]=nil


      print_char "s"
      return
    else
      print_char(".")
      #puts ("Duplicate HOL entry; not saved.")
    end
    hd
  end

  def find_antcat_taxa(name)
    @antcat_taxa_dictionary[name.downcase]
  end

  # @param [Object] hol_hash
  # Does a query using HOLs "getTaxonInfo" api.
  def get_additional_hol_taxon_info hol_hash
#    hol_taxa_hash = get_taxa_command "getTaxaFromText?name=#{query_string}&limit=10&nameOnly=N"
#http://osuc.biosci.ohio-state.edu/OJ_Break/getTaxonInfo?tnuid=30148&inst_id=0&format=json&key=FBF57A9F7A666FC0E0430100007F0CDC
    @print_char = @print_char +1
    results = run_hol_command "getTaxonInfo?tnuid=#{hol_hash['tnuid']}"
    hol_hash.rel_type = results['rel_type']
    puts results
  end

  # An array of antcat species taxa and a genus taxa (the latter for diagnosis and reporting)
  def compare_hol_and_antcat_species antcat_species, genus

    # Iterate over the hol dictionary. Match against the antcat_species
    # that we've passed in (should be all the species in the antcat genus)
    # When we get a match, write a record to the database table and remove
    # the hol entry from the dictionary
    antcat_species.each do |antcat_taxa|
      antcat_name = antcat_taxa.name.name
      # puts ("Got " + antcat_species.count.to_s + " antcat results")

      hol_species = @hol_dictionary[antcat_name.downcase]
      if hol_species.nil?
        #puts ("No HOL equivalant for " + antcat_name)
        check_and_save_hol_for_taxon antcat_taxa
        next
      end
      hol_species.each do |hol_hash|
        save_hol_data hol_hash, antcat_taxa.id
        print_char "M"
        #puts ("Found and matched " + antcat_name)
      end

      @hol_dictionary.delete(antcat_name.downcase)
    end
    # After we've matched every known antcat item against the returned items from
    # HOL, we have these HOL items left over that don't seem to have antcat equivalants
    @hol_dictionary.each do |missing_hols_tuple|
      missing_hols_tuple[1].each do |hol_hash|
        # do a find against antcat internally
        antcat_taxa = find_antcat_taxa hol_hash['name']
        if (antcat_taxa.nil? || antcat_taxa.count==0)
          #puts ("No antcat equivalant for " + hol_hash['name'].to_s)
          print_char "A"
          save_hol_data hol_hash, nil
        elsif (antcat_taxa.count == 1)
          #puts (" Found a match in antcat; HOL returned "+ hol_hash['name']+" that isn't in genus "+genus.name_cache+" according to antcat.")
          print_char "q"
          save_hol_data hol_hash, antcat_taxa[0]
        else
          hol_hash['many_antcat_references']=1
          save_hol_data hol_hash, antcat_taxa[0]
          puts (" ** Got multiple antcat taxa; marked")
        end
      end
    end
  end
end

# Cases -
# multiple possible antcat references
#  -  mark a field as "has multiple antcat true"
#    Causes:
#      Homonyms
#      ?
# multiple possible hol references
#  - do a post-facto query where we mark has multiple hol true" (scan HolData for multiple instances of a name)
#    Causes:
#      Homonyms
#      ?
# No matching antcat record
# -

# Ideas - for something listed as "original combo" query for subsequent, and vice versa.

# index on tnuid
# find on each first
