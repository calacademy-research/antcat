# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private

  def parse_tribes_lists subfamily
    return '' unless @type == :tribes_list
    Progress.method

    parsed_text = ''
    while @type == :tribes_list
      parsed_text << @paragraph
      @parse_result[:tribes].each do |tribe|
        attributes = {name: tribe[:name], subfamily: subfamily, fossil: tribe[:fossil], status: 'valid'}
        attributes.merge!(incertae_sedis_in: 'subfamily') if @parse_result[:incertae_sedis]
        Tribe.create! attributes
      end
      parse_next_line
    end
    parsed_text
  end

  def parse_tribes subfamily
    Progress.method
    parse_tribe(subfamily) while @type == :tribe_header
  end

  def parse_tribe subfamily
    Progress.method

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]

    parse_next_line
    expect :family_group_headline
    taxonomic_history = @paragraph

    parse_next_line
    taxonomic_history << parse_tribe_taxonomic_history

    tribe = Tribe.find_by_name(name)
    raise "Tribe #{name} doesn't exist" unless tribe

    # genera lists can appear before or after junior synonyms
    taxonomic_history << parse_genera_lists(:tribe, subfamily: subfamily, tribe: tribe)
    taxonomic_history << parse_junior_synonyms_of_tribe(tribe)
    taxonomic_history << parse_genera_lists(:tribe, subfamily: subfamily, tribe: tribe)
    taxonomic_history << parse_ichnotaxa_list(subfamily: subfamily, tribe: tribe)
    taxonomic_history << parse_references_sections(:references_section_header, :see_under_references_section_header)
    taxonomic_history << parse_see_also_references_section

    parse_genera
    parse_genera_incertae_sedis_in_tribe
    parse_ichnotaxa

    tribe.reload.update_attributes taxonomic_history: clean_taxonomic_history(taxonomic_history)
  end

  def parse_ichnotaxa_list parents
    return '' unless @type == :ichnotaxa_list
    parsed_text = @paragraph
    #do something with ichnogenus
    parse_next_line
    parsed_text
  end

  def parse_see_also_references_section
    return '' unless @type == :see_also_references_section_header
    Progress.method
    parsed_text = @paragraph
    parse_next_line
    parsed_text
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
    return '' unless @type == :junior_synonyms_of_tribe_header
    Progress.method

    parsed_text = @paragraph
    parse_next_line

    parsed_text << parse_junior_synonym_of_tribe(tribe) while @type == :family_group_headline

    parsed_text
  end

  def parse_junior_synonym_of_tribe tribe
    Progress.method
    parsed_text = ''
    name = @parse_result[:tribe_name] || @parse_result[:subtribe_name] || @parse_result[:family_or_subfamily_name]
    fossil = @parse_result[:fossil]
    taxonomic_history = @paragraph
    parse_next_line
    taxonomic_history << parse_tribe_taxonomic_history
    tribe = Tribe.create! name: name, fossil: fossil, status: 'synonym', synonym_of: tribe,
                          subfamily: tribe.subfamily, taxonomic_history: clean_taxonomic_history(taxonomic_history)
    parsed_text << taxonomic_history
  end

  def parse_tribe_taxonomic_history
    Progress.method
    taxonomic_history, @parsed_tribe_taxonomic_history = parse_taxonomic_history :tribe_taxonomic_history_item
    taxonomic_history
  end

  def parsed_tribe_taxonomic_history
    @parsed_tribe_taxonomic_history
  end
end
