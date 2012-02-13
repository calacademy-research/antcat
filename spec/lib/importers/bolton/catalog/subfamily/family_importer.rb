# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private

  def parse_family
    parse_family_header
    parse_family_record
    parse_family_child_lists
    parse_family_references
    parse_family_children
  end

  def parse_family_header
    consume :family_centered_header
    consume :family_header
  end

  def parse_family_record
    headline = consume :family_group_headline
    consume :taxonomic_history_header
    taxonomic_history = consume :family_taxonomic_history

    family = Family.import({
      :protonym => headline[:protonym],
      :type_genus => headline[:type_genus],
      :note => headline[:note],
      :taxonomic_history => [Bolton::Catalog::TextToTaxt.convert(taxonomic_history[:items])]
    })
    Progress.info "Created #{family.name}"
  end

  ######################################################
  def parse_family_child_lists
    consume :extant_subfamilies_list
    consume :extinct_subfamilies_list
    consume :extant_genera_incertae_sedis_in_family_list
    consume :extinct_genera_incertae_sedis_in_family_list
    consume :extant_genera_excluded_from_family_list
    consume :extinct_genera_excluded_from_family_list
    consume :genus_group_nomina_nuda_in_family_list
  end

  ##############################################################
  def parse_family_references
    parse_world_references
    parse_regional_catalogs
    parse_regional_fauna
  end

  def parse_world_references
    consume :family_references_header
    parse_family_reference_sections
  end

  def parse_regional_catalogs
    consume :regional_catalogues_header
    parse_family_reference_sections_with_inline_headings
  end

  def parse_regional_fauna
    consume :regional_and_national_faunas_header
    parse_family_reference_sections
  end

  def parse_family_reference_sections
    while @type == :uppercase_line
      parse_family_reference_section
    end
  end

  def parse_family_reference_sections_with_inline_headings
    while @type && @type != :regional_and_national_faunas_header
      parse_next_line
    end
  end

  def parse_family_reference_section
    parse_next_line :text
    parse_next_line
  end

  ##############################################################
  def parse_family_children
    consume :genera_incertae_sedis_and_exclusions_header
    parse_genera_incertae_sedis_in_family
    parse_genera_excluded_from_family
    parse_unavailable_family_group_names_in_family
    parse_genus_group_nomina_nuda_in_family
  end

  def parse_genera_incertae_sedis_in_family
    consume :genera_incertae_sedis_header
    while parse_genus(:incertae_sedis_in => 'family'); end
  end

  def parse_genera_excluded_from_family
    consume :genera_excluded_from_family_header
    consume :genera_excluded_from_family_note
    while parse_genus(:status => 'excluded'); end
  end

  def parse_unavailable_family_group_names_in_family
    consume :unavailable_family_group_names_header
    parse_unavailable_family_group_name while @type == :unavailable_family_group_name_header
  end

  def parse_unavailable_family_group_name
    return unless @type == :unavailable_family_group_name_header
    loop do
      parse_next_line :unavailable_family_group_name_detail
      break unless @type == :unavailable_family_group_name_detail
    end
  end

  def parse_genus_group_nomina_nuda_in_family
    consume :genus_group_nomina_nuda_header
    while parse_genus({:status => 'nomen nudum'}, :header => :genus_nomen_nudum_header); end
  end

end
