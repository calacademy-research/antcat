# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer

  def parse_subfamily
    return unless @type == :subfamily_centered_header
    Progress.method

    parse_next_line

    name = consume(:subfamily_header)[:name]
    headline = consume :family_group_headline
    fossil = headline[:protonym][:fossil]
    history = parse_taxonomic_history

    subfamily = Subfamily.import(
      name: name,
      fossil: fossil,
      protonym: headline[:protonym],
      type_genus: headline[:type_genus],
      taxonomic_history: history,
    )
    Progress.info "Created #{subfamily.name}"

    parse_subfamily_child_lists subfamily
    parse_subfamily_reference_sections subfamily
    parse_subfamily_children subfamily

    true
  end

  def parse_subfamily_children subfamily
    parse_tribes subfamily
    parse_genera subfamily: subfamily
    parse_tribes_incertae_sedis subfamily
    parse_genera_incertae_sedis 'subfamily', subfamily: subfamily
    parse_genera_of_hong subfamily
    parse_collective_group_names
  end

  def parse_subfamily_child_lists subfamily
    parse_tribes_lists subfamily
    parse_genera_lists
    parse_collective_group_names_list
  end

  def parse_subfamily_reference_sections taxon
    Progress.method
    parse_reference_sections taxon, :references_section_header, :regional_and_national_faunas_header
  end

  def parse_collective_group_names_list
    return unless @type == :collective_group_name_list
    Progress.method

    parse_next_line
  end

  def parse_collective_group_names
    return unless @type == :collective_group_names_header
    Progress.method

    parse_next_line
    consume :collective_group_name_header
    consume :genus_headline
  end

  def parse_genera_of_hong subfamily
    return unless @type == :genera_of_hong_header
    Progress.method

    parse_next_line
    while parse_genus subfamily: subfamily, hong: true, incertae_sedis_in: 'subfamily'; end
  end

end
