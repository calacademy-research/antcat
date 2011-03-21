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
#   In NGC-Spcan-cr.htm, removed extra paragraph in Cephalotes texanus
#   In NGC-Spg-las.htm, removed extra paragraph in Lasius murphyi

class Bolton::SpeciesCatalog < Bolton::Catalog
  def import
    Species.delete_all
    parse_header || parse_failed if @line
    parse_see_under || parse_genus_section || parse_failed while @line
    super
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
    @subspecies_for_species[species.name] = @parse_result[:subspecies] || []

    parse_next_line
    true
  end

  def parse_subspecies genus
    return unless @type == :subspecies

    subspecies = Subspecies.new :name => @parse_result[:name], :fossil => @parse_result[:fossil], :status => @parse_result[:status], :taxonomic_history => @paragraph
    @species_for_subspecies[subspecies] = @parse_result[:species]

    parse_next_line
    true
  end

  def parse_note
    return unless @type == :note
    parse_next_line
  end

  def save_subspecies genus
    @species_for_subspecies.each do |subspecies, species_name|
      species = Species.find_by_genus_id_and_name genus.id, species_name
      unless species
        Progress.error "Subspecies #{genus.name} #{species_name} #{subspecies.name} was seen but not its species"
        return
      end
      unless @subspecies_for_species[species_name].include? subspecies.name
        Progress.error "Subspecies #{genus.name} #{species_name} #{subspecies.name} was seen but it was not in its species's subspecies list" 
        return
      end
      subspecies.species = species
      subspecies.save!
    end

    @subspecies_for_species.each do |species_name, subspecies_list|
      species = Species.find_by_genus_id_and_name genus.id, species_name
      subspecies_list.each do |subspecies_name|
        Progress.error "Subspecies #{genus.name} #{species.name} #{subspecies_name} was in its species's subspecies list but was not seen" unless species.subspecies.find_by_name subspecies_name
      end
    end
  end
end
