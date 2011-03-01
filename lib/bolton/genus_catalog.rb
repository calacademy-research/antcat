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
    super
  end

  def grammar
    Bolton::GenusCatalogGrammar
  end

  def parse_section
    return unless [:genus, :subgenus, :collective_group_name].include? @type

    if @type == :genus
      import_genus
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

  private
  def import_genus
    status = @parse_result[:status].present? ? @parse_result[:status].to_s : nil
    subfamily = @parse_result[:subfamily].present? ? Subfamily.find_by_name(@parse_result[:subfamily]) : nil
    tribe = @parse_result[:tribe].present? ? Tribe.find_by_name(@parse_result[:tribe]) : nil
    synonym_of = @parse_result[:synonym_of].present? ? Taxon.find_by_name(@parse_result[:synonym_of]) : nil
    homonym_resolved_to = @parse_result[:homonym_resolved_to].present? ? Taxon.find_by_name(@parse_result[:homonym_resolved_to]) : nil

    genera = Genus.find :all, :conditions => ['name = ?', @parse_result[:name]]
    if genera.size > 1
      Progress.puts "More than one genus for #{@parse_result[:name]}"
    elsif genera.empty?
      raise "Genus #{@parse_result[:name]} not found" unless ['synonym', 'homonym', 'unavailable', 'unidentifiable', 'unresolved_homonym_and_synonym'].include? status
      Genus.create! :name => @parse_result[:name], :status => status
    else
      genus = genera.first
      if genus.status != status
        Progress.puts "Genus #{genus.name} status changing from #{genus.status} to #{status}"
      end
      if subfamily && genus.subfamily != subfamily
        Progress.puts "Genus #{genus.name} subfamily changing from #{genus.subfamily} to #{subfamily}"
      end
      if tribe && genus.tribe != tribe
        Progress.puts "Genus #{genus.name} tribe changing from #{genus.tribe} to #{tribe}"
      end
      if genus.incertae_sedis_in != @parse_result[:incertae_sedis_in]
        Progress.puts "Genus #{genus.name} incertae_sedis_in changing from #{genus.incertae_sedis_in} to #{@parse_result[:incertae_sedis_in]}"
      end
      if genus.synonym_of != synonym_of
        Progress.puts "Genus #{genus.name} synonym_of changing from #{genus.synonym_of} to #{@parse_result[:synonym_of]}"
      end
      if genus.homonym_resolved_to != homonym_resolved_to
        Progress.puts "Genus #{genus.name} homonym_resolved_to changing from #{genus.homonym_resolved_to} to #{@parse_result[:homonym_resolved_to]}"
      end
    end
  end
end
