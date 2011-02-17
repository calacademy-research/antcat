#  The Bolton genus catalog files are NGC-GEN.A-L.docx and NGC-GEN.M-Z.docx.

#  To convert a genus catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:genera
#  This generates log/bolton_genus_import.log
#
#  Manual edits:
#   In NGC-GEN.A-L.htm, surrounded ASPHINCTANILLOIDES in bold red

class Bolton::GenusCatalog < Bolton::Catalog
  def import
    Taxon.delete_all
    parse_header || parse_failed if @line
    parse_genus_section || parse_failed while @line
    super
  end

  def grammar
    Bolton::GenusCatalogGrammar
  end

  def parse_genus_section
    return unless [:subgenus, :genus].include? @type

    if @type == :genus
      Genus.import @parse_result.merge :taxonomic_history => @paragraph
    end

    parse_next_line
    parse_genus_detail
  end

  def parse_genus_detail
    while @line && (parse_genus_detail_line); end
    true
  end

  def parse_genus_detail_line
    return unless @type == :genus_detail_line
    parse_next_line
    true
  end

end
