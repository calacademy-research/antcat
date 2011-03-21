#  A Bolton species catalog file is named NGC-Sp<start-letters>-<end-letters>.docx,
#  e.g. NGC-Spa-an.docx

#  To convert a species catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:species
#  This generates log/bolton_species_catalog.log
#
#  Manual edits:
#   In NGC-Spap-ca.htm, made Aphaenogaster simonelli red and bold
#   In NGC-Spcan-cr.htm, removed extra paragraph in Cephalotes texanus
#   In NGC-Spg-las.htm, removed extra paragraph in Lasius murphyi

class Bolton::SpeciesCatalog < Bolton::Catalog
  def import
    @subspecies_errors = 0
    Species.delete_all
    Subspecies.delete_all

    parse_header || parse_failed if @line
    parse_see_under || parse_genus_section || parse_failed while @line

    super
    Progress.puts "#{@subspecies_errors} subspecies errors"
  end

  def grammar
    Bolton::SpeciesCatalogGrammar
  end

  def parse_see_under
    return unless @type == :see_under
    parse_next_line
  end

  def parse_genus_section
    return unless @type == :genus

    @subspecies_for_species = {}
    @species_for_subspecies = {}

    genus = Genus.find_by_name @parse_result[:name]
    Progress.error "Genus '#{@parse_result[:name]}' did not exist" unless genus

    parse_next_line
    parse_species_lines genus

    save_subspecies genus if genus
    true
  end

  def parse_species_lines genus
    while @line && (parse_note || parse_species(genus) || parse_subspecies(genus)); end
    true
  end

  def parse_species genus
    return unless @type == :species

    species = Species.create! :name => @parse_result[:name], :fossil => @parse_result[:fossil], :status => @parse_result[:status], :genus => genus, :taxonomic_history => @paragraph
    @subspecies_for_species[species.name] = @parse_result[:subspecies] || [] unless species.invalid?

    parse_next_line
    true
  end

  def parse_subspecies genus
    return unless @type == :subspecies

    subspecies = Subspecies.new :name => @parse_result[:name], :fossil => @parse_result[:fossil], :status => @parse_result[:status], :taxonomic_history => @paragraph
    @species_for_subspecies[subspecies] = @parse_result[:species] || []

    parse_next_line
    true
  end

  def parse_note
    return unless @type == :note
    parse_next_line
  end

  def save_subspecies genus
    @species_for_subspecies.each do |subspecies, species_name|
      next unless species = find_species_for_subspecies(genus, subspecies, species_name)
      subspecies.species = species
      subspecies.save!
    end

    @subspecies_for_species.each do |species_name, subspecies_list|
      species = Species.find_by_genus_id_and_name genus.id, species_name
      subspecies_list.each do |subspecies_name|
        Progress.error "Subspecies #{genus.name} #{species.name} #{subspecies_name} was in its species's subspecies list but was not seen" unless species.subspecies.find_by_name subspecies_name
        @subspecies_errors += 1
      end
    end

  end

  def find_species_for_subspecies genus, subspecies, species_name
    species = find_senior_synonym_of genus, species_name
    unless species
      species = find_species_synonym genus, subspecies, species_name
      return species if species
      Progress.error "Subspecies #{genus.name} #{species_name} #{subspecies.name} was seen but not its species"
      @subspecies_errors += 1
      return
    end
    unless @subspecies_for_species[species.name].include? subspecies.name
      Progress.error "Subspecies #{genus.name} #{species_name} #{subspecies.name} was seen but it was not in its species's subspecies list" 
      @subspecies_errors += 1
      return
    end
    species
  end

  def find_species_synonym genus, subspecies, species_name
    # is this subspecies in anyone's subspecies list?
    @subspecies_for_species.each do |name, list|
      # if so, we assume we have a species synonym
      if list && list.include?(subspecies.name)
        species = Species.find_by_genus_id_and_name genus.id, name
        synonym = Species.create! :name => species_name, :fossil => species.fossil, :status => 'synonym', :synonym_of => species, :genus => genus
        Progress.error "Subspecies #{genus.name} #{species_name} #{subspecies.name} was seen but not its species, but a species synonym was created (#{species.name})"
        return species
      end
    end
    nil
  end

  def find_senior_synonym_of genus, species_name
    species = Species.find_by_genus_id_and_name genus.id, species_name
    return unless species
    species = species.synonym_of while species.synonym? && species.synonym_of
    species
  end

end
