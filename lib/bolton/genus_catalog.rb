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
      import_genus @parse_result
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

  def import_genus record
    record[:status] = status = record[:status].present? ? record[:status].to_s : nil
    record[:incertae_sedis_in] = record[:incertae_sedis_in].present? ? record[:incertae_sedis_in].to_s : nil

    if record[:subfamily]
      if ['Aculeata', 'Symphyta', 'Apocrita', 'Homoptera', 'Ichneumonidae', 'Embolemidae'].include? record[:subfamily]
        subfamily = nil
      else
        subfamily = Subfamily.find_by_name(record[:subfamily])
        raise "Genus #{record[:name]} has unknown subfamily #{record[:subfamily]}" unless subfamily
      end
      record[:subfamily] = subfamily
    end

    if record[:tribe]
      tribe = Tribe.find_by_name(record[:tribe])
      raise "Genus #{record[:name]} has unknown tribe #{record[:tribe]}" unless tribe
      record[:tribe] = tribe
    end

    if record[:synonym_of]
      synonym_of = Taxon.find_by_name(record[:synonym_of])
      raise "Genus #{record[:name]} has unknown synonym_of #{record[:synonym_of]}" unless
        synonym_of || ['Myrma', 'Myrmhopla'].include?(record[:synonym_of])
      record[:synonym_of] = synonym_of
    end

    if record[:homonym_resolved_to]
      homonym_resolved_to = Taxon.find_by_name(record[:homonym_resolved_to])
      raise "Genus #{record[:name]} has unknown homonym_resolved_to #{record[:homonym_resolved_to]}" unless homonym_resolved_to
      record[:homonym_resolved_to] = homonym_resolved_to
    end

    genera = Genus.find :all, :conditions => ['name = ?', record[:name]]
    if genera.size > 1
      Progress.puts "More than one genus for #{record[:name]}"
    elsif genera.empty?
      add_genus record
    else
      add_genus_with_different_status(record) ||
      update_genus_with_nil_status(record) ||
      update_genus_with_nonnil_status(record)
    end
  end

  private
  def add_genus record
    raise "Genus #{record[:name]} not found" unless ['synonym', 'homonym', 'unavailable', 'unidentifiable', 'unresolved_homonym_and_synonym'].include? record[:status]
    Genus.create! :name => record[:name], :status => record[:status], :synonym_of => record[:synonym_of],
                  :homonym_resolved_to => record[:homonym_resolved_to], :fossil => record[:fossil]
  end

  def add_genus_with_different_status record
    return unless record[:status]
    return unless genus = Genus.find_by_name(record[:name])
    return unless genus.status
    return unless genus.status != record[:status]
    Progress.warning "Adding #{record[:status]} genus #{record[:name]} which already existed with #{genus.status} status"
    Genus.create! :name => record[:name], :status => record[:status], :subfamily => record[:subfamily], :tribe => record[:tribe], :synonym_of => record[:synonym_of], :homonym_resolved_to => record[:homonym_resolved_to]
  end

  def update_genus_with_nil_status record
    return unless record[:status]
    return unless genus = Genus.find_by_name(record[:name])
    return if genus.status
    genus.update_attributes :status => record[:status], :subfamily => record[:subfamily], :tribe => record[:tribe], :fossil => record[:fossil], :incertae_sedis_in => record[:incertae_sedis_in]
  end

  def update_genus_with_nonnil_status record
    return unless record[:status]
    return unless genus = Genus.find_by_name(record[:name])
    return if genus.status != record[:status]
    raise "Updating genus #{genus.name} with different attributes" unless
      record[:subfamily] == genus.subfamily &&
      record[:tribe] == genus.tribe &&
      record[:synonym_of] == genus.synonym_of &&
      record[:homonym_resolved_to] == genus.homonym_resolved_to &&
      record[:incertae_sedis_in] == genus.incertae_sedis_in &&
      !!record[:fossil] == !!genus.fossil?
  end
end
