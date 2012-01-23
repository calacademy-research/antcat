# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private

  def parse_tribes_lists subfamily
    return unless @type == :tribes_list
    Progress.method
    parse_next_line while @type == :tribes_list
  end

  def parse_tribes subfamily
    Progress.method
    parse_tribe subfamily while @type == :tribe_header
  end

  def parse_tribe subfamily
    Progress.method

    name = consume(:tribe_header)[:name]
    headline = consume :family_group_headline
    fossil = headline[:protonym][:fossil]
    history = parse_taxonomic_history

    tribe = Tribe.import(
      name: name,
      fossil: fossil,
      protonym: headline[:protonym],
      type_genus: headline[:type_genus],
      taxonomic_history: history,
    )
    Progress.info "Created #{tribe.name}"

    # genera lists can appear before or after junior synonyms
    parse_genera_lists :tribe, subfamily: subfamily, tribe: tribe
    parse_junior_synonyms_of_tribe tribe
    parse_genera_lists :tribe, subfamily: subfamily, tribe: tribe
    parse_ichnotaxa_list subfamily: subfamily, tribe: tribe
    parse_references_sections :references_section_header, :see_under_references_section_header
    parse_see_also_references_section

    parse_genera
    parse_genera_incertae_sedis_in_tribe
    parse_ichnotaxa

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

  def parse_genera_incertae_sedis_in_tribe
    return unless @type == :genera_incertae_sedis_in_tribe_header
    Progress.method

    parse_next_line
    parse_genus while @type == :genus_header
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

  def parse_junior_synonyms_of_tribe tribe
    return unless @type == :junior_synonyms_of_tribe_header
    Progress.method

    parse_next_line
    parse_junior_synonym_of_tribe(tribe) while @type == :family_group_headline
  end

  def parse_junior_synonym_of_tribe tribe
    Progress.method
    #name = @parse_result[:tribe_name] || @parse_result[:subtribe_name] || @parse_result[:family_or_subfamily_name]
    #fossil = @parse_result[:fossil]
    #history = @paragraph
    parse_next_line
    parse_tribe_taxonomic_history
    #tribe = Tribe.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => tribe,
                          #:subfamily => tribe.subfamily, :taxonomic_history => clean_taxonomic_history(history)
  end

end
