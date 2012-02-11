# coding: UTF-8
class Importers::Bolton::Catalog::Subfamily::Importer < Importers::Bolton::Catalog::Importer
  private

  def parse_subgenus attributes = {}, options = {}
    options = options.reverse_merge :header => :genus_header
    parsing_synonym = attributes[:synonym_of]
    if parsing_synonym
      return if @type != :subgenus_headline && @type != :genus_headline
    else
      return if @type != options[:header]
    end
    Progress.method

    unless parsing_synonym
      name = @parse_result[:name]
      parse_next_line
    end

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
    info_message << " synonym of #{parsing_synonym.name}" if parsing_synonym
    Progress.info info_message

    parse_homonym_replaced_by_subgenus subgenus
    parse_synonyms_of_subgenus subgenus

    subgenus
  end

  def parse_homonym_replaced_by_subgenus replaced_by_subgenus
    parse_subgenus({
      status: 'homonym', homonym_replaced_by: replaced_by_subgenus,
      genus: replaced_by_subgenus.genus, subfamily: replaced_by_subgenus.subfamily, tribe: replaced_by_subgenus.tribe},
      header: :homonym_replaced_by_genus_header)
  end

  def parse_synonyms_of_subgenus subgenus
    return unless @type == :junior_synonyms_of_subgenus_header
    Progress.method

    parse_next_line
    attributes = {synonym_of: subgenus, status: 'synonym', subfamily: subgenus.subfamily, tribe: subgenus.tribe, genus: subgenus.genus}

    while parse_subgenus attributes, header: :subgenus_headline; end
  end

  def parse_subgenera attributes = {}
    return '' unless @type == :subgenera_header
    Progress.method

    parse_next_line
    parse_next_line if @type == :texts
    parse_subgenus(attributes, header: :subgenus_header) while @type == :subgenus_header
  end

<<<<<<< HEAD
||||||| merged common ancestors
  def parse_junior_synonym_of_subgenus subgenus
    parsed_text = ''
    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    genus = Subgenus.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => subgenus,
                             :genus => subgenus.genus, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    parsed_text << taxonomic_history
  end


=======
  def parse_junior_synonym_of_subgenus subgenus
    parsed_text = ''
    name = @parse_result[:name]
    fossil = @parse_result[:fossil] || false
    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    genus = Subgenus.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => subgenus,
                             :genus => subgenus.genus, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    parsed_text << taxonomic_history
  end


>>>>>>> master
end
