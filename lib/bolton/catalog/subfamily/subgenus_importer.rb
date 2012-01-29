# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private

  def parse_subgenus attributes = {}, options = {}
    options = options.reverse_merge :header => :genus_header
    return unless @type == options[:header]
    Progress.method

    name = @parse_result[:name]
    parse_next_line

    headline = consume :genus_headline
    name ||= headline[:protonym][:subgenus_name] || headline[:protonym][:genus_name]
    fossil ||= headline[:protonym][:fossil]

    history = parse_taxonomic_history

    subgenus = Subgenus.import(
      :name => name,
      :genus => attributes[:genus],
      :fossil => fossil,
      :protonym => headline[:protonym],
      :note => headline[:note].try(:[], :text),
      :type_species => headline[:type_species],
      :taxonomic_history => history,
      :attributes => attributes
    )
    info_message = "Created #{subgenus.name}"
    Progress.info info_message

    parse_homonym_replaced_by_subgenus subgenus
    parse_junior_synonyms_of_subgenus subgenus

    subgenus
  end

  def parse_homonym_replaced_by_subgenus replaced_by_subgenus
    parse_subgenus({
      status: 'homonym', homonym_replaced_by: replaced_by_subgenus,
      genus: replaced_by_subgenus.genus, subfamily: replaced_by_subgenus.subfamily, tribe: replaced_by_subgenus.tribe},
      header: :homonym_replaced_by_genus_header)
  end

  def parse_junior_synonyms_of_subgenus subgenus
    return unless @type == :junior_synonyms_of_subgenus_header
    Progress.method

    parse_next_line
    attributes = {synonym_of: subgenus, status: 'synonym', subfamily: subgenus.subfamily, tribe: subgenus.tribe, genus: subgenus.genus, header: :subgenus_header}

    while parse_subgenus attributes, header: :subgenus_headline; end
  end

  def parse_subgenera attributes = {}
    return '' unless @type == :subgenera_header
    Progress.method

    parse_next_line
    parse_next_line if @type == :texts
    parse_subgenus(attributes, header: :subgenus_header) while @type == :subgenus_header
  end

end
