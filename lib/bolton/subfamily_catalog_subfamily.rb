class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def parse_subfamily
    return unless @type == :subfamily_centered_header
    Progress.log 'parse_subfamily'

    parse_next_line
    expect :subfamily_header

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history

    subfamily = Subfamily.find_by_name(name)
    raise "Subfamily #{name} doesn't exist" unless subfamily

    taxonomic_history << parse_tribes_lists(subfamily)
    taxonomic_history << parse_genera_lists(:subfamily, :subfamily => subfamily)
    taxonomic_history << parse_collective_group_names_list(subfamily)
    taxonomic_history << skip(:other)

    subfamily.update_attributes :taxonomic_history => taxonomic_history, :fossil => fossil

    parse_tribes subfamily

    parse_genera

    parse_genera_incertae_sedis

    true
  end

  def parse_collective_group_names_list subfamily
    return '' unless @type == :collective_group_name_list
    Progress.log 'parse_collective_group_names'

    parsed_text = @paragraph
    @parse_result[:names].each do |name, fossil|
      Genus.create! :name => name, :subfamily => subfamily, :fossil => fossil, :status => 'unidentifiable'
    end
    parse_next_line
    parsed_text
  end

end
