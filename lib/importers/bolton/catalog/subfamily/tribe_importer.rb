# coding: UTF-8
class Importers::Bolton::Catalog::Subfamily::Importer < Importers::Bolton::Catalog::Importer

  def parse_tribe subfamily
    Progress.method

    name = consume(:tribe_header)[:name]
    headline = consume :family_group_headline
    fossil = headline[:protonym][:fossil]
    history = parse_taxonomic_history

    tribe = Tribe.import(
      name: name,
      fossil: fossil,
      subfamily: subfamily,
      protonym: headline[:protonym],
      type_genus: headline[:type_genus],
      taxonomic_history: history,
    )
    Progress.info "Created #{tribe.name}"

    # genera lists can appear before or after synonyms
    parse_genera_lists
    parse_synonyms_of_tribe subfamily, tribe
    parse_genera_lists
    parse_ichnotaxa_list subfamily: subfamily, tribe: tribe
    parse_reference_sections tribe, :references_section_header, :see_under_references_section_header
    parse_see_also_references_section

    parse_genera subfamily: subfamily, tribe: tribe
    parse_genera_incertae_sedis_in_tribe  subfamily: subfamily, tribe: tribe
    parse_ichnotaxa

  end

  def parse_tribe_synonym subfamily, senior_synonym
    return unless @type == :family_group_headline
    Progress.method

    headline = consume :family_group_headline
    name = headline[:protonym][:tribe_name] || headline[:protonym][:subtribe_name] || headline[:protonym][:family_or_subfamily_name]
    fossil = headline[:protonym][:fossil]

    history = parse_taxonomic_history

    tribe = Tribe.import(
      name: name,
      fossil: fossil,
      subfamily: subfamily,
      status: 'synonym',
      synonym_of: senior_synonym,
      protonym: headline[:protonym],
      type_genus: headline[:type_genus],
      taxonomic_history: history,
    )
    Progress.info "Created #{tribe.name}: synonym for #{senior_synonym.name}"
    true
  end

  def parse_tribes_lists subfamily
    return unless @type == :tribes_list
    Progress.method
    parse_next_line while @type == :tribes_list
  end

  def parse_tribes subfamily
    Progress.method
    parse_tribe subfamily while @type == :tribe_header
  end


  def parse_ichnotaxa_list parents
    return unless @type == :ichnotaxa_list
    #do something with ichnogenus
    parse_next_line
  end

  def parse_see_also_references_section
    return unless @type == :see_also_references_section_header
    Progress.method
    parse_next_line
  end

  def parse_genera_incertae_sedis_in_tribe attributes
    return unless @type == :genera_incertae_sedis_in_tribe_header
    Progress.method

    parse_next_line
    parse_genus attributes.merge(incertae_sedis_in: 'tribe') while @type == :genus_header
  end

  def parse_ichnotaxa
    return unless @type == :ichnotaxa_header
    Progress.method

    parse_next_line :ichnogenus_header
    # do something with the header

    parse_next_line :ichnogenus_headline
    # do something with the headline

    parse_next_line
  end

  def parse_tribes_incertae_sedis subfamily
    return unless @type == :tribes_incertae_sedis_header
    Progress.method

    parse_next_line
    parse_tribe subfamily while @type == :tribe_header
  end

  ################################################
  def parse_synonyms_of_tribe subfamily, tribe
    return unless @type == :junior_synonyms_of_tribe_header
    Progress.method

    parse_next_line
    while parse_tribe_synonym(subfamily, tribe); end
  end

end
