#  A Bolton subfamily catalog file is named NN. NAME.docx,
#    e.g. 01. FORMICIDAE.docx
#  and yes, the first one is actually for the whole family, rather
#  than s 'supersubfamily' (group of subfamilies)
#
#  To convert a subfamily catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:subfamilies
#  This generates log/bolton_subfamily_catalog.log

class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def import
    Taxon.delete_all

    parse_family
    parse_supersubfamilies 
    #while @line
      #parse_incertae_sedis_in_family || parse_incertae_sedis_in_subfamily || parse_subfamily || parse_genus || parse_tribe || parse_other || parse_next_line
    #end
    super
  end

  def parse_family
    return unless @type == :family_header

    parse_next_line 
    parse_next_line while @type == :other

    parse_family_summary &&
    parse_genera_incertae_sedis_in_family &&
    parse_genera_excluded_from_family &&
    parse_unavailable_group_names &&
    parse_genus_group_nomina_nuda
  end

  def parse_family_summary
    parse_extant_subfamilies &&
    parse_extinct_subfamilies &&
    parse_extant_genera_incertae_sedis_in_family &&
    parse_extinct_genera_incertae_sedis_in_family &&
    parse_extant_genera_excluded_from_family &&
    parse_extinct_genera_excluded_from_family &&
    parse_genus_group_nomina_nuda
  end

  def parse_extant_subfamilies
    parse_failed and return unless @type == :extant_subfamilies
    @parse_result[:subfamilies].each do |subfamily|
      Subfamily.create! :name => subfamily, :status => 'valid'
    end
    parse_next_line
  end

  def parse_extinct_subfamilies
    parse_failed and return unless @type == :extinct_subfamilies
    @parse_result[:subfamilies].each do |subfamily|
      Subfamily.create! :name => subfamily, :status => 'valid', :fossil => true
    end
    parse_next_line
  end

  def parse_extant_genera_incertae_sedis_in_family
    parse_failed and return unless @type == :extant_genera_incertae_sedis_in_family
    @parse_result[:genera].each do |genus|
      Genus.create! :name => genus, :status => 'valid', :incertae_sedis_in => 'family'
    end
    parse_next_line
  end

  def parse_extinct_genera_incertae_sedis_in_family
    parse_failed and return unless @type == :extinct_genera_incertae_sedis_in_family
    @parse_result[:genera].each do |genus|
      Genus.create! :name => genus, :status => 'valid', :incertae_sedis_in => 'family', :fossil => true
    end
    parse_next_line
  end

  def parse_extant_genera_excluded_from_family
    parse_failed and return unless @type == :extant_genera_excluded_from_family
    @parse_result[:genera].each do |genus|
      Genus.create! :name => genus, :status => 'excluded'
    end
    parse_next_line
  end

  def parse_extinct_genera_excluded_from_family
    parse_failed and return unless @type == :extinct_genera_excluded_from_family
    @parse_result[:genera].each do |genus|
      Genus.create! :name => genus, :status => 'excluded', :fossil => true
    end
    parse_next_line
  end

  def parse_genus_group_nomina_nuda
    parse_failed and return unless @type == :genus_group_nomina_nuda_in_family
    parse_next_line
  end

  def parse_genera_incertae_sedis_in_family
  end

  def parse_genera_excluded_from_family
  end

  def parse_unavailable_group_names
  end

  def parse_genus_group_nomina_nuda
  end

  def parse_supersubfamilies
    while @type == :supersubfamily_header
      parse_next_line
      parse_subfamily
    end
  end

  def parse_incertae_sedis_in_family
    return unless @type == :incertae_sedis_in_family_header
    @incertae_sedis_in_family = true
    parse_next_line
  end

  def parse_incertae_sedis_in_subfamily
    return unless @type == :incertae_sedis_in_subfamily_header
    @incertae_sedis_in_subfamily = true
    parse_next_line
  end

  def parse_subfamily
    raise unless @type == :subfamily_header
    parse_next_line
    raise unless @type == :subfamily

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history

    subfamily = Subfamily.find_by_name name
    raise "Subfamily doesn't exist" unless subfamily

    subfamily.update_attributes :taxonomic_history => taxonomic_history
  end

  def parse_tribe
    return unless @type == :tribe
    @incertae_sedis_in_subfamily = false

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history

    raise "Tribe #{name} already exists" if Tribe.find_by_name name
    raise "Tribe #{name} has no subfamily" unless @current_subfamily

    @current_tribe = Tribe.create! :name => name, :subfamily => @current_subfamily, :fossil => fossil, :taxonomic_history => taxonomic_history
  end

  def parse_genus
    return unless @type == :genus

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history

    raise "Genus #{name} already exists" if Genus.find_by_name name

    attributes = {:name => name, :subfamily => @current_subfamily, :tribe => @current_tribe, :fossil => fossil, :taxonomic_history => taxonomic_history}

    if @incertae_sedis_in_family
      attributes[:incertae_sedis_in] = 'family'
    elsif @incertae_sedis_in_subfamily
      raise "Genus #{name} is incertae sedis in subfamily with no subfamily" unless @current_subfamily
      attributes[:incertae_sedis_in] = 'subfamily'
    elsif !@current_subfamily
      raise "Genus #{name} has no subfamily"
    elsif !@current_tribe
      raise "Genus #{name} has no tribe"
    end

    Genus.create! attributes
  end

  def parse_taxonomic_history
    taxonomic_history = ''
    loop do
      parse_next_line
      break if !@line || @type != :other
      taxonomic_history << @paragraph
    end
    taxonomic_history
  end

  def parse_other
    return unless @type == :incertae_sedis_in_subfamily_header
    @current_tribe = nil
    parse_next_line
  end

  def get_filenames filenames
    super filenames.select {|filename| File.basename(filename) =~ /^\d\d\. /}
  end

  def grammar
    Bolton::SubfamilyCatalogGrammar
  end

end
