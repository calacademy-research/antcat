# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer

  def parse_genus attributes = {}, options = {}
    parsing_synonym = attributes[:synonym_of]
    options = options.reverse_merge :header => :genus_header
    return unless @type == options[:header]
    Progress.method

    unless parsing_synonym
      name = @parse_result[:genus_name] || @parse_result[:name]
      parse_next_line
    end

    headline = consume :genus_headline
    name ||= headline[:protonym][:genus_name]
    fossil ||= headline[:protonym][:fossil]

    history = parse_taxonomic_history

    genus = Genus.import(
      :name => name,
      :fossil => fossil,
      :protonym => headline[:protonym],
      :note => headline[:note].try(:[], :text),
      :type_species => headline[:type_species],
      :taxonomic_history => history,
      :attributes => attributes
    )
    info_message = "Created #{genus.name}"
    info_message << " synonym of #{parsing_synonym}" if parsing_synonym
    Progress.info info_message

    parse_junior_synonyms_of_genus genus
    parse_homonym_replaced_by_genus genus
    parse_genus_references genus

    genus
  end

  def parse_genus_references genus
    case @type
    when :genus_references_header
      parsed_genus_name = @parse_result[:genus_name]
      return if parsed_genus_name.present? && parsed_genus_name != genus.name
    when :genus_references_see_under
    else
      return
    end
    Progress.method

    title_only = @type == :genus_references_see_under

    texts = Bolton::Catalog::Grammar.parse(@line, root: :text).value
    title = Bolton::Catalog::TextToTaxt.convert texts[:text]

    references = nil
    unless title_only
      parse_next_line
      references = Bolton::Catalog::TextToTaxt.convert @parse_result[:texts]
    end

    genus.reference_sections.create! title: title, references: references
    
    parse_next_line
  end

  ################################################
  def parse_homonym_replaced_by_genus replaced_by_genus
    genus = parse_genus({:status => 'homonym'}, :header => :homonym_replaced_by_genus_header)
    return '' unless genus
    Progress.method

    genus.update_attributes homonym_replaced_by: replaced_by_genus, subfamily: replaced_by_genus.subfamily, tribe: replaced_by_genus.tribe
  end

  ################################################
  def parse_junior_synonyms_of_genus genus
    return unless @type == :junior_synonyms_of_genus_header
    Progress.method

    parse_next_line
    attributes = {synonym_of: genus, status: 'synonym', subfamily: genus.subfamily, tribe: genus.tribe}
    while parse_genus attributes, header: :genus_headline; end
  end

  ################################################
  def parse_genera_lists
    parse_next_line while @type == :genera_list
  end

  #################################################################
  # parse a subfamily or tribe's genera
  def parse_genera attributes = {}
    return unless @type == :genera_header || @type == :genus_header
    Progress.method

    parse_next_line if @type == :genera_header
    parse_genus attributes while @type == :genus_header
  end

  def parse_genera_of_hong
    return unless @type == :genera_of_hong_header
    Progress.method

    parse_next_line
    parse_genus while @type == :genus_header
  end

  def parse_genera_incertae_sedis rank, attributes = {}, expected_header = :genera_incertae_sedis_header
    return unless @type == expected_header
    Progress.method

    parse_next_line
    parse_genus attributes.reverse_merge(incertae_sedis_in: rank) while @type == :genus_header
  end

end
