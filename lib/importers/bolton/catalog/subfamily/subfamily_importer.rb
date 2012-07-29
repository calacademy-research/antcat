# coding: UTF-8
class Importers::Bolton::Catalog::Subfamily::Importer < Importers::Bolton::Catalog::Importer

  def parse_subfamily options = {skip_centered_header: true}
    if options[:skip_centered_header]
      return unless @type == :subfamily_centered_header
      parse_next_line
    end

    Progress.method
    name = consume(:subfamily_header)[:name]
    headline = consume :family_group_headline
    fossil = headline[:protonym][:fossil]
    history = parse_taxonomic_history

    subfamily = Subfamily.import(
      subfamily_name: name,
      fossil: fossil,
      protonym: headline[:protonym],
      type_genus: headline[:type_genus],
      taxonomic_history: history,
    )
    Progress.info "Created #{subfamily.inspect}"

    parse_subfamily_child_lists subfamily
    parse_subfamily_reference_sections subfamily
    parse_subfamily_children subfamily

    true
  end

  ###########
  def parse_subfamily_child_lists subfamily
    parse_tribes_lists subfamily
    parse_genera_lists
    parse_collective_group_names_list
  end

  ###########
  def parse_subfamily_reference_sections taxon
    Progress.method
    parse_reference_sections taxon, :references_section_header, :regional_and_national_faunas_header
  end

  ###########
  def parse_subfamily_children subfamily
    parse_tribes subfamily
    parse_genera subfamily: subfamily
    parse_tribes_incertae_sedis subfamily
    parse_genera_incertae_sedis 'subfamily', subfamily: subfamily
    parse_genera_of_hong subfamily
    parse_collective_group_names subfamily
  end

  def parse_collective_group_names_list
    return unless @type == :collective_group_name_list
    Progress.method

    parse_next_line
  end

  def parse_collective_group_names subfamily
    return unless @type == :collective_group_names_header
    Progress.method

    parse_next_line
    attributes = {subfamily: subfamily, status: 'collective group name'}
    while parse_genus attributes, header: :collective_group_name_header; end
  end

  def parse_genera_of_hong subfamily
    return unless @type == :genera_of_hong_header
    Progress.method

    parse_next_line
    while parse_genus subfamily: subfamily, hong: true, incertae_sedis_in: 'subfamily'; end
  end

  def parse_unavailable_family_group_name
    return unless @type == :unavailable_family_group_name_header
    Progress.method

    name = @parse_result[:name]

    parse_next_line :unavailable_family_group_name_detail
    protonym = @parse_result[:protonym]
    headline_notes_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(@parse_result[:additional_notes])
    taxonomic_history = []
    loop do
      parse_next_line
      break unless @type == :texts
      taxonomic_history << Importers::Bolton::Catalog::TextToTaxt.convert(@parse_result[:texts])
    end

    subfamily = Subfamily.import(
      subfamily_name:     name,
      status:             'unavailable',
      protonym:           protonym,
      taxonomic_history:  taxonomic_history,
      headline_notes_taxt:headline_notes_taxt,
    )
    Progress.info "Created #{subfamily.inspect}"
    true
  end

end
