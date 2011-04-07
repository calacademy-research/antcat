class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def parse_tribes_lists subfamily
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
  end

  def parse_tribes subfamily
    Progress.log 'parse_tribes'
    parse_tribe(subfamily) while @type == :tribe_header
  end

  def parse_tribe subfamily
    Progress.log 'parse_tribe'

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]

    parse_next_line
    expect :family_group_line
    taxonomic_history = @paragraph

    taxonomic_history << parse_taxonomic_history

    tribe = Tribe.find_by_name(name)
    raise "Tribe #{name} doesn't exist" unless tribe

    # genera lists can appear before or after junior synonyms
    taxonomic_history << parse_genera_lists(:tribe, :subfamily => subfamily, :tribe => tribe)
    taxonomic_history << parse_junior_synonyms_of_tribe(tribe)
    taxonomic_history << parse_genera_lists(:tribe, :subfamily => subfamily, :tribe => tribe)
    taxonomic_history << parse_references

    parse_genera
    parse_genera_incertae_sedis_in_tribe

    tribe.reload.update_attributes :taxonomic_history => clean_taxonomic_history(taxonomic_history)
  end

  def parse_genera_incertae_sedis_in_tribe
    return unless @type == :genera_incertae_sedis_in_tribe_header
    Progress.info 'parse_genera_incertae_sedis_in_tribe'

    parse_next_line
    parse_genus while @type == :genus_header
  end

  def parse_junior_synonyms_of_tribe tribe
    return '' unless @type == :junior_synonyms_of_tribe_header
    Progress.log 'parse_junior_synonyms_of_tribe'

    parsed_text = @paragraph
    parse_next_line

    parsed_text << parse_junior_synonym_of_tribe(tribe) while @type == :family_group_line

    parsed_text
  end

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
  end

end
