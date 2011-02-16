#  A Bolton species catalog file is named NGC-Sp<start-letters>-<end-letters>.docx,
#  e.g. NGC-Spa-an.docx

#  To convert a species catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:species
#  This generates log/bolton_species_import.log
#
#  Manual edits:
#   In NGC-Spg-las.htm, removed extra paragraph in Lasius murphyi
#   In NGC-Spcan-cr.htm, removed extra paragraph in Cephalotes texanus

class Bolton::SpeciesCatalog < Bolton::Catalog
  def import
    Species.delete_all
    @genus = nil
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

    unless Genus.find_by_name @parse_result[:name]
      Progress.error "Genus '#{@parse_result[:name]}' did not exist"
    end

    @genus = Genus.import :name => @parse_result[:name], :fossil => @parse_result[:fossil], :status => @parse_result[:status].to_s

    parse_next_line
    parse_species_lines
  end

  def parse_species_lines
    while @line && (parse_note || parse_species); end
    true
  end

  def parse_species
    return unless @type == :species || @type == :subspecies

    if @type == :species
      Species.create! :name => @parse_result[:name], :fossil => @parse_result[:fossil], :status => @parse_result[:status].to_s, :genus => @genus
    end

    parse_next_line
    true
  end

  def parse_note
    return unless @type == :note
    parse_next_line
  end
end
