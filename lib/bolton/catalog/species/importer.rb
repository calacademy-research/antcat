# coding: UTF-8
#  A Bolton species catalog file is named NGC-Sp<start-letters>-<end-letters>.docx,
#  e.g. NGC-Spa-an.docx

#  To convert a species catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:species

class Bolton::Catalog::Species::Importer < Bolton::Catalog::Importer
  def import
    @species_not_seen_count = 0
    @species_seen_but_list_is_nil_count = 0
    @subspecies_not_in_list_count = 0
    @species_synonynm_created_for_subspecies_count = 0
    @subspecies_in_list_but_not_seen_count = 0
    @genus_not_found_count = 0
    ::Species.delete_all
    ::Subspecies.delete_all

    parse_header || parse_failed if @line
    parse_see_under || parse_genus_section || parse_failed while @line

    super
    Progress.puts "#{@species_not_seen_count} species for subspecies not seen"
    Progress.puts "#{@species_seen_but_list_is_nil_count} species seen but it had no list"
    Progress.puts "#{@subspecies_not_in_list_count} subspecies created, even though not in their species list"
    Progress.puts "#{@subspecies_in_list_but_not_seen_count} subspecies in a species list but not seen"
    Progress.puts "#{@species_not_seen_count + @species_seen_but_list_is_nil_count + @subspecies_not_in_list_count + @subspecies_in_list_but_not_seen_count} total subspecies errors"
    Progress.puts "#{@species_synonynm_created_for_subspecies_count} species synonyms created"
    Progress.puts "#{@genus_not_found_count} genera not found"
  end

  def grammar
    Bolton::Catalog::Species::Grammar
  end

  def parse_failed
    raise "Parse failed"
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
    unless genus
      Progress.error "Genus '#{@parse_result[:name]}' did not exist"
      @genus_not_found_count += 1
    end

    parse_next_line
    parse_species_lines genus

    save_subspecies genus if genus
    true
  end

  def parse_species_lines genus
    while @line && (parse_note || parse_species(genus) || parse_species_see_under(genus) || parse_subspecies(genus)); end
    true
  end

  def parse_species genus
    return unless @type == :species

    species = ::Species.create! name: @parse_result[:name], fossil: @parse_result[:fossil], status: @parse_result[:status], genus: genus,
      taxonomic_history: clean_taxonomic_history(@paragraph)
    @subspecies_for_species[species.name] = @parse_result[:subspecies] || [] unless species.invalid?

    parse_next_line
    true
  end

  def parse_species_see_under genus
    return unless @type == :species_see_under

    ::Species.create! name: @parse_result[:name], fossil: @parse_result[:fossil], status: 'recombined',
      genus: genus, taxonomic_history: clean_taxonomic_history(@paragraph)

    parse_next_line
    true
  end

  def parse_subspecies genus
    return unless @type == :subspecies

    subspecies = Subspecies.new name: @parse_result[:name], fossil: @parse_result[:fossil], status: @parse_result[:status], taxonomic_history: clean_taxonomic_history(@paragraph)
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
      species = ::Species.find_by_genus_id_and_name genus.id, species_name
      subspecies_list.each do |subspecies_name|
        unless species.subspecies.find_by_name subspecies_name
          Progress.error "Subspecies #{genus.name} #{species.name} #{subspecies_name} was in its species's subspecies list but was not seen"
          @subspecies_in_list_but_not_seen_count += 1
        end
      end
    end

  end

  def find_species_for_subspecies genus, subspecies, species_name
    species = find_senior_synonym_of genus, species_name
    unless species
      species = find_species_synonym genus, subspecies, species_name
      return species if species
      Progress.error "Subspecies #{genus.name} #{species_name} #{subspecies.name} was seen but not its species"
      @species_not_seen_count += 1
      return
    end

    unless @subspecies_for_species[species.name]
      Progress.error "Subspecies #{genus.name} #{species_name} #{subspecies.name} was seen but its species (#{species.name}) subspecies list is nil"
      @species_seen_but_list_is_nil_count += 1
      return
    end
    unless @subspecies_for_species[species.name].include? subspecies.name
      Progress.error "Subspecies #{genus.name} #{species_name} #{subspecies.name} was seen and created even though it was not in its species's subspecies list"
      @subspecies_not_in_list_count += 1
      return species
    end
    species
  end

  def find_species_synonym genus, subspecies, species_name
    # is this subspecies in anyone's subspecies list?
    @subspecies_for_species.each do |name, list|
      # if so, we assume we have a species synonym
      if list && list.include?(subspecies.name)
        species = ::Species.find_by_genus_id_and_name genus.id, name
        synonym = ::Species.create! name: species_name, fossil: species.fossil, status: 'synonym', synonym_of: species, genus: genus
        Progress.error "Subspecies #{genus.name} #{species_name} #{subspecies.name} was seen but not its species, but a species synonym was created (#{species.name})"
        @species_synonynm_created_for_subspecies_count += 1
        return species
      end
    end
    nil
  end

  def find_senior_synonym_of genus, species_name
    species = ::Species.find_by_genus_id_and_name genus.id, species_name
    return unless species
    species = species.synonym_of while species.synonym? && species.synonym_of
    species
  end

  def get_filenames filenames
    super #filenames.select {|filename| File.basename(filename) =~ /Sp(a-an)|(st-tet)/}
  end
end
