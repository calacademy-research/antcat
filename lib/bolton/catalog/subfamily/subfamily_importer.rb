# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private

  def parse_subfamily
    return unless @type == :subfamily_centered_header
    Progress.method

    parse_next_line
    expect :subfamily_header

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]

    get :family_group_headline
    taxonomic_history = @paragraph

    parse_next_line
    taxonomic_history << parse_subfamily_taxonomic_history

    subfamily = ::Subfamily.find_by_name(name)
    raise "Subfamily #{name} doesn't exist" unless subfamily

    taxonomic_history << parse_subfamily_child_lists(subfamily)
    taxonomic_history << parse_subfamily_references_sections

    subfamily.update_attributes :taxonomic_history => clean_taxonomic_history(taxonomic_history), :fossil => fossil

    parse_subfamily_children subfamily

    true
  end

  def parse_subfamily_children subfamily
    parse_tribes subfamily
    parse_genera
    parse_tribes_incertae_sedis subfamily
    parse_genera_incertae_sedis
    parse_genera_of_hong
    parse_collective_group_names
  end

  def parse_subfamily_child_lists subfamily
    parsed_text = ''
    parsed_text << parse_tribes_lists(subfamily)
    parsed_text << parse_genera_lists(:subfamily, :subfamily => subfamily)
    parsed_text << parse_collective_group_names_list
  end

  def parse_subfamily_references_sections
    Progress.method
    parse_references_sections :references_section_header, :regional_and_national_faunas_header
  end

  def parse_subfamily_taxonomic_history
    Progress.method
    taxonomic_history, @parsed_subfamily_taxonomic_history = parse_taxonomic_history :subfamily_taxonomic_history_item
    taxonomic_history
  end

  def parsed_subfamily_taxonomic_history
    @parsed_subfamily_taxonomic_history
  end

  def parse_collective_group_names_list
    return '' unless @type == :collective_group_name_list
    Progress.method

    parsed_text = @paragraph
    parse_next_line
    parsed_text
  end

  def parse_collective_group_names
    return '' unless @type == :collective_group_names_header
    Progress.method

    parse_next_line
    consume :collective_group_name_header
    consume :genus_headline
  end

end
