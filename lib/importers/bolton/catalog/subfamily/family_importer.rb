# coding: UTF-8
class Importers::Bolton::Catalog::Subfamily::Importer < Importers::Bolton::Catalog::Importer
  private

  def parse_family
    parse_family_header
    family = parse_family_record
    parse_family_child_lists
    parse_family_references family
    parse_family_children
  end

  def parse_family_header
    consume :family_centered_header
    consume :family_header
  end

  def parse_family_record
    headline = consume :family_group_headline
    consume :history_header
    history = consume :family_history

    family = Family.import(
      protonym:   headline[:protonym],
      type_genus: headline[:type_genus],
      note:       headline[:note],
      history:    [Importers::Bolton::Catalog::TextToTaxt.convert(history[:items])],
    )
    Progress.info "Created #{family.inspect}"
    family
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
  def parse_family_references family
    reference_sections = []
    parse_world_references family, reference_sections
    parse_regional_catalogs family, reference_sections
    parse_regional_fauna family, reference_sections

    family.import_reference_sections reference_sections
  end

  def parse_world_references family, reference_sections
    expect :family_references_header
    title = convert_line_to_taxt @line
    parse_next_line
    parse_family_reference_sections family, title, reference_sections
  end

  def parse_regional_catalogs family, reference_sections
    expect :regional_catalogues_header
    title = convert_line_to_taxt @line
    parse_next_line
    parse_family_reference_sections_with_inline_headings family, title, reference_sections
  end

  def parse_regional_fauna family, reference_sections
    expect :regional_and_national_faunas_header
    title = convert_line_to_taxt @line
    parse_next_line
    parse_family_reference_sections family, title, reference_sections
  end

  def parse_family_reference_sections family, title, reference_sections
    while @type == :uppercase_line
      subtitle = convert_line_to_taxt @line
      parse_family_reference_section family, title, subtitle, reference_sections
      title = nil
    end
  end

  def parse_family_reference_sections_with_inline_headings family, title, reference_sections
    while @type == :texts
      references = convert_line_to_taxt @line
      reference_sections << {title_taxt: title, references_taxt: references}
      parse_next_line
      title = nil
    end
  end

  def parse_family_reference_section family, title, subtitle, reference_sections
    parse_next_line :text
    references = convert_line_to_taxt @line
    reference_sections << {title_taxt: title, subtitle_taxt: subtitle, references_taxt: references}
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
    while parse_genus(:status => 'excluded from Formicidae'); end
  end

  def parse_unavailable_family_group_names_in_family
    consume :unavailable_family_group_names_header
    while parse_unavailable_family_group_name; end
  end

  def parse_genus_group_nomina_nuda_in_family
    consume :genus_group_nomina_nuda_header
    while parse_genus({:status => 'nomen nudum'}, :header => :genus_nomen_nudum_header); end
  end

end
