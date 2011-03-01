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
    while @line
      parse_incertae_sedis_in_family || parse_incertae_sedis_in_subfamily || parse_subfamily || parse_genus || parse_tribe || parse_other || parse_next_line
    end
    super
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
    return unless @type == :subfamily
    @incertae_sedis_in_family = false
    @incertae_sedis_in_subfamily = false

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history

    raise "Subfamily #{name} already exists" if Subfamily.find_by_name name

    @current_subfamily = Subfamily.create! :name => name, :fossil => fossil, :taxonomic_history => taxonomic_history
  end

  def parse_tribe
    return unless @type == :tribe
    @incertae_sedis_in_subfamily = false

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history

    raise "Tribe #{name} already exists" if Tribe.find_by_name name

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
      raise "Genus #{name} is incertae sedis in subfamily with no subfamily" if !@current_subfamily
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
