class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def parse_subfamily
    Progress.log 'parse_subfamily'
    return unless @type == :subfamily_centered_header
    parse_next_line
    expect :subfamily_header

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history

    subfamily = Subfamily.find_by_name(name)
    raise "Subfamily #{name} doesn't exist" unless subfamily

    subfamily.update_attributes :taxonomic_history => taxonomic_history, :fossil => fossil

    parse_tribes_lists subfamily
    parse_genera_lists :subfamily, :subfamily => subfamily
    parse_collective_group_names_list subfamily

    skip :other

    parse_tribes subfamily

    parse_genera

    parse_genera_incertae_sedis
    true
  end

  def parse_tribes_lists subfamily
    Progress.log 'parse_tribes_lists'
    while @type == :tribes_list
      @parse_result[:tribes].each do |tribe, fossil|
        attributes = {:name => tribe, :subfamily => subfamily, :fossil => fossil, :status => 'valid'}
        attributes.merge!(:incertae_sedis_in => 'subfamily') if @parse_result[:incertae_sedis]
        Tribe.create! attributes
      end
      parse_next_line
    end
  end

  def parse_collective_group_names_list subfamily
    Progress.log 'parse_collective_group_names'
    return unless @type == :collective_group_name_list
    @parse_result[:names].each do |name, fossil|
      Genus.create! :name => name, :subfamily => subfamily, :fossil => fossil, :status => 'unidentifiable'
    end
    parse_next_line
  end

  def parse_tribes subfamily
    Progress.log 'parse_tribes'
    parse_tribe(subfamily) while @type == :tribe_header
  end

  def parse_tribe subfamily
    Progress.log 'parse_tribe'
    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history

    tribe = Tribe.find_by_name(name)
    raise "Tribe #{name} doesn't exist" unless tribe

    tribe.update_attributes :taxonomic_history => taxonomic_history

    parse_genera_lists :tribe, :subfamily => subfamily, :tribe => tribe

    skip :other
    parse_genera
  end

  def parse_genera
    Progress.log 'parse_genera'
    return unless @type == :genera_header || @type == :genus
    parse_next_line if @type == :genera_header
    parse_genus while @type == :genus
  end

  def parse_genera_incertae_sedis
    Progress.log 'parse_genera_incertae_sedis'
    return unless @type == :genera_incertae_sedis_header
    parse_next_line
    parse_genus while @type == :genus
  end

end
