#  The Bolton genus catalog files are NGC-GEN.A-L.docx and NGC-GEN.M-Z.docx.

#  To convert a genus catalog file from Bolton to a format we can use:
#  1) Open the file in Word
#  2) Save it as web page in data/bolton

#  To import these files, run
#    rake bolton:import:genera
#  This generates log/bolton_genus_catalog.log
#
#  Manual edits:
#   In NGC-GEN.A-L.htm, surrounded ASPHINCTANILLOIDES in bold red
#   In NGC-GEN.M-Z.htm, surrounded PARAPRIONOPELTA in bold red
#   In NGC-GEN.M-Z.htm, surrounded PSEUDOATTA in bold red

class Bolton::GenusCatalog < Bolton::Catalog
  def import
    parse_header || parse_failed if @line
    parse_section || parse_failed while @line
    show_genuses_referred_to_but_without_their_own_section
    super
  end

  def grammar
    Bolton::GenusCatalogGrammar
  end

  def parse_section
    return unless [:genus, :subgenus, :collective_group_name].include? @type

    if @type == :genus
      Genus.import @parse_result.merge :taxonomic_history => @paragraph
    elsif @type == :subgenus
      Subgenus.import @parse_result.merge :taxonomic_history => @paragraph
    end

    parse_next_line
    parse_section_details
  end

  def parse_section_details
    while @line && parse_section_detail; end
    true
  end

  def parse_section_detail
    return unless @type == :section_detail
    parse_next_line
    true
  end

  def show_genuses_referred_to_but_without_their_own_section
    Genus.all(:conditions => 'status IS NULL', :order => :name).each do |genus|
      synonyms_pointing_to = Genus.all(:conditions => ['synonym_of_id = ?', genus.id]).map{|e| %{#{e.name}}}.join(', ')
      homonyms_pointing_to = Genus.all(:conditions => ['homonym_resolved_to_id = ?', genus.id]).map{|e| %{#{e.name}}}.join(', ')
      Progress.error <<-END
No section for #{genus.name}
Synonyms pointing to it: #{synonyms_pointing_to}
Homonyms pointing to it: #{homonyms_pointing_to}
      END
    end
  end

end
