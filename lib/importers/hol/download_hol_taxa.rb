# coding: UTF-8

#
#  Step 1 and 2 of ?
# starting point: downlad_hol_taxa_hash. Imports hol_taxon_data. This is just top level stuff, n
# ot enough details to link to much of anything.
# we start with each genus that antcat knows about, and asks HOL for that genus. It then asks for the children
# of that genus. This is used as the basis for future quries.
#
# This process has the potential of missing a new genus that antcat has never heard of.
# So there is a second (optional) entry point "download_children_of_type" that pulls a given category
# (hardcoded) from hol, and if it's not already something that we have a copy of, saves it.
#
#

#
# Import top level HOL taxa data based on names.
# Entry points are compare_with_antcat and  compare_subspecies.
#
class Importers::Hol::DownloadHolTaxa
  include HolCommands

  def initialize
    @print_char=0
    @hol_dictionary = {}
    @tnuid_details_dictionary={}
    @antcat_taxa_dictionary={}
    for hol_data in HolDatum.all
      @tnuid_details_dictionary[hol_data.tnuid]=nil
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
  def downlad_hol_taxa_hash
    #HolDatum.delete_all

    #genus = Genus.find_by_name 'Bilobomyrma'
    genus_count = 0
    for genus in Genus.order(:name_cache).all
      if (genus_count >= 0)
        antcat_species = genus.species
        get_hol_species genus.name.to_s, genus_count
        compare_hol_and_antcat_species antcat_species, genus
      end
      if genus_count > 100000
        exit
      end

      genus_count = genus_count +1
    end
    save_hol_data
  end

  def add_to_hol_dict hol_hash
    if @hol_dictionary[hol_hash['tnuid']].nil?
      @hol_dictionary[hol_hash['tnuid'].downcase] = []
    end
    ary = @hol_dictionary[hol_hash['tnuid'].downcase]
    ary.concat [hol_hash]
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
        unless @tnuid_details_dictionary.has_key?(includedTaxa['tnuid'])
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


  def find_antcat_taxa(name)
    @antcat_taxa_dictionary[name.downcase]
  end


  def save_hol_data
    @hol_dictionary.each do |missing_hols_tuple|
      missing_hols_tuple[1].each do |hol_hash|
        save_hol_taxa hol_hash
      end
    end
  end

  #==============================================================


  # runs and compares all TAXON TYPE (hardocded), one at a time
  # pull all *foo* by name and compare them
  def download_children_of_type
    subspecies_count=0
    # Could iterate over Tribe, etc. Genus is already handled.
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
      save_hol_taxa hol_hash
    end

  end


  def save_hol_taxa hol_hash
    if  @tnuid_details_dictionary.has_key?(hol_hash['tnuid'])
      print_char ","
      return
    end
    hd = create_hol_datum_from_hash(hol_hash)


    records = nil
    begin
      records = HolDatum.find_by_tnuid hd['tnuid']
    rescue ActiveRecord::RecordNotFound => e

    end
    if records.nil?
      hd.save
      @tnuid_details_dictionary[hol_hash['tnuid']]=nil


      print_char "s"
      return
    else
      print_char(".")
      #puts ("Duplicate HOL entry; not saved.")
    end
    hd
  end

end

