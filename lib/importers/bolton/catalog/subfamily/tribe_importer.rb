# coding: UTF-8
<<<<<<< HEAD
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer

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
||||||| merged common ancestors
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private
=======
class Importers::Bolton::Catalog::Subfamily::Importer < Importers::Bolton::Catalog::Importer
  private
>>>>>>> master

  def parse_tribes_lists subfamily
<<<<<<< HEAD
    return unless @type == :tribes_list
    Progress.method
    parse_next_line while @type == :tribes_list
||||||| merged common ancestors
    return '' unless @type == :tribes_list
    Progress.log 'parse_tribes_lists'

    parsed_text = ''
    while @type == :tribes_list
      parsed_text << @paragraph
      @parse_result[:tribes].each do |tribe|
        attributes = {:name => tribe[:name], :subfamily => subfamily, :fossil => tribe[:fossil], :status => 'valid'}
        attributes.merge!(:incertae_sedis_in => 'subfamily') if @parse_result[:incertae_sedis]
        Tribe.create! attributes
      end
      parse_next_line
    end
    parsed_text
=======
    return '' unless @type == :tribes_list
    Progress.log 'parse_tribes_lists'

    parsed_text = ''
    while @type == :tribes_list
      parsed_text << @paragraph
      @parse_result[:tribes].each do |tribe|
        attributes = {:name => tribe[:name], :subfamily => subfamily, :fossil => tribe[:fossil] || false, :status => 'valid'}
        attributes.merge!(:incertae_sedis_in => 'subfamily') if @parse_result[:incertae_sedis]
        Tribe.create! attributes
      end
      parse_next_line
    end
    parsed_text
>>>>>>> master
  end

  def parse_tribes subfamily
    Progress.method
    parse_tribe subfamily while @type == :tribe_header
  end

<<<<<<< HEAD
||||||| merged common ancestors
  def parse_tribe subfamily
    Progress.log 'parse_tribe'

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
=======
  def parse_tribe subfamily
    Progress.log 'parse_tribe'

    name = @parse_result[:name]
    fossil = @parse_result[:fossil] || false
>>>>>>> master

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

<<<<<<< HEAD
  ################################################
  def parse_synonyms_of_tribe subfamily, tribe
    return unless @type == :junior_synonyms_of_tribe_header
    Progress.method

    parse_next_line
    while parse_tribe_synonym(subfamily, tribe); end
||||||| merged common ancestors
  def parse_junior_synonym_of_tribe tribe
    Progress.log 'parse_junior_synonym_of_tribe'
    parsed_text = ''
    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    tribe = Tribe.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => tribe,
                          :subfamily => tribe.subfamily, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    parsed_text << taxonomic_history
=======
  def parse_junior_synonym_of_tribe tribe
    Progress.log 'parse_junior_synonym_of_tribe'
    parsed_text = ''
    name = @parse_result[:name]
    fossil = @parse_result[:fossil] || false
    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    tribe = Tribe.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => tribe,
                          :subfamily => tribe.subfamily, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    parsed_text << taxonomic_history
>>>>>>> master
  end

end
