class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def parse_subgenera genus
    return '' unless @type == :subgenera_header
    Progress.log 'parse_subgenera'

    parsed_text = @paragraph
    parse_next_line

    parsed_text << skip(:other)

    expect :subgenus_header
    parsed_text << parse_subgenus(genus) while @type == :subgenus_header

    parsed_text
  end

  def parse_subgenus genus
    return unless @type == :subgenus_header

    name = @parse_result[:name]
    parsed_text = @paragraph

    parse_next_line
    expect :genus_line

    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    parsed_text << taxonomic_history

    raise "Subgenus #{name} already exists" if Subgenus.find_by_name name
    subgenus = Subgenus.create! :name => name, :status => 'valid', :genus => genus, :taxonomic_history => taxonomic_history
    Progress.info "Created #{subgenus.name}"

    parsed_text
  end

end
