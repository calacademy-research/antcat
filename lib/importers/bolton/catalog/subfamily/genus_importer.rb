# coding: UTF-8
class Importers::Bolton::Catalog::Subfamily::Importer < Importers::Bolton::Catalog::Importer

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

    history = parse_history name

    if attributes[:status] == 'synonym' and name == 'Ancylognathus'
      genus = Genus.find_by_name 'Ancylognathus'
      Progress.info "Skipping Ancylognathus 'synonym'"
    else
      genus = Genus.import(
        :genus_name => name,
        :fossil => fossil,
        :protonym => headline[:protonym],
        :note => headline[:note].try(:[], :text),
        :type_species => headline[:type_species],
        :history => history,
        :attributes => attributes
      )
      info_message = "Created #{genus.inspect}"
      info_message << " synonym of #{parsing_synonym.inspect}" if parsing_synonym
      Progress.info info_message

      # look for subgenera before...
      parse_subgenera genus: genus
      parse_synonyms_of_genus genus
      # ...and after looking for synonyms
      parse_subgenera genus: genus
      parse_homonym_replaced_by_genus genus
      parse_homonym_and_synonym_of_genus genus
      parse_genus_references genus
    end

    genus

  end

  def parse_genus_references genus
    Progress.method
    case @type
    when :genus_references_header
      parsed_genus_name = @parse_result[:genus_name]
      return if parsed_genus_name.present? && parsed_genus_name != genus.name.to_s
    when :genus_references_see_under
    else
      return
    end

    title_only = @type == :genus_references_see_under
    references_only = false

    loop do
      texts = Importers::Bolton::Catalog::Grammar.parse(@line, root: :text).value
      title = Importers::Bolton::Catalog::TextToTaxt.convert texts[:text], genus.name.to_s

      references = nil
      unless title_only || references_only
        parse_next_line
        references = Importers::Bolton::Catalog::TextToTaxt.convert @parse_result[:texts], genus.name.to_s
      end

      if references_only
        references = title
        title = ''
      end

      genus.reference_sections.create! title_taxt: title, references_taxt: references

      parse_next_line

      break unless @type == :texts

      references_only = true
    end

  end

  def parse_homonym_replaced_by_genus replaced_by_genus
    Progress.method
    parse_genus({
      status: 'homonym', homonym_replaced_by: replaced_by_genus,
      subfamily: replaced_by_genus.subfamily, tribe: replaced_by_genus.tribe},
      header: :homonym_replaced_by_genus_header)
  end

  def parse_synonyms_of_genus genus
    return unless @type == :junior_synonyms_of_genus_header
    Progress.method

    parse_next_line
    attributes = {synonym_of: genus, status: 'synonym', subfamily: genus.subfamily, tribe: genus.tribe}

    while parse_genus attributes, header: :genus_headline; end
  end

  def parse_homonym_and_synonym_of_genus genus
    return unless @type == :junior_homonym_and_junior_synonym_of_genus_header
    Progress.method

    parse_next_line
    attributes = {synonym_of: genus, status: 'synonym', subfamily: genus.subfamily, tribe: genus.tribe}

    while parse_genus attributes, header: :genus_headline; end
  end

  def parse_genera_lists
    parse_next_line while @type == :genera_list
  end

  # parse a subfamily or tribe's genera
  def parse_genera attributes = {}
    return unless @type == :genera_header || @type == :genus_header
    Progress.method

    parse_next_line if @type == :genera_header
    parse_genus attributes while @type == :genus_header
  end

  def parse_genera_incertae_sedis rank, attributes = {}, expected_header = :genera_incertae_sedis_header
    return unless @type == expected_header
    Progress.method

    parse_next_line
    parse_genus attributes.reverse_merge(incertae_sedis_in: rank) while @type == :genus_header
  end

end
