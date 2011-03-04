class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def parse_subfamily
    return unless @type == :subfamily_centered_header
    parse_next_line
    expect :subfamily_header

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history

    subfamily = Subfamily.find_by_name name
    raise "Subfamily doesn't exist" unless subfamily

    subfamily.update_attributes :taxonomic_history => taxonomic_history

    parse_tribes_lists subfamily
    parse_genera_incertae_sedis_lists subfamily
  end

  def parse_tribes_lists subfamily
    while @type == :tribes_list
      @parse_result[:tribes].each do |tribe, fossil|
        attributes = {:name => tribe, :subfamily => subfamily, :fossil => fossil, :status => 'valid'}
        attributes.merge!(:incertae_sedis_in => 'subfamily') if @parse_result[:incertae_sedis]
        Tribe.create! attributes
      end
      parse_next_line
    end
  end

  def parse_genera_incertae_sedis_lists subfamily
    while @type == :genera_incertae_sedis_list
      @parse_result[:genera].each do |genus, fossil|
        Genus.create! :name => genus, :subfamily => subfamily, :fossil => fossil, :incertae_sedis_in => 'subfamily', :status => 'valid'
      end
      parse_next_line
    end
  end

  #def parse_incertae_sedis_in_subfamily
    #return unless @type == :incertae_sedis_in_subfamily_header
    #@incertae_sedis_in_subfamily = true
    #parse_next_line
  #end

  #def parse_tribe
    #return unless @type == :tribe
    #@incertae_sedis_in_subfamily = false

    #name = @parse_result[:name]
    #fossil = @parse_result[:fossil]
    #taxonomic_history = parse_taxonomic_history

    #raise "Tribe #{name} already exists" if Tribe.find_by_name name
    #raise "Tribe #{name} has no subfamily" unless @current_subfamily

    #@current_tribe = Tribe.create! :name => name, :subfamily => @current_subfamily, :fossil => fossil, :taxonomic_history => taxonomic_history
  #end

  #def parse_genus
    #return unless @type == :genus

    #name = @parse_result[:name]
    #fossil = @parse_result[:fossil]
    #taxonomic_history = parse_taxonomic_history

    #raise "Genus #{name} already exists" if Genus.find_by_name name

    #attributes = {:name => name, :subfamily => @current_subfamily, :tribe => @current_tribe, :fossil => fossil, :taxonomic_history => taxonomic_history}

    #if @incertae_sedis_in_family
      #attributes[:incertae_sedis_in] = 'family'
    #elsif @incertae_sedis_in_subfamily
      #raise "Genus #{name} is incertae sedis in subfamily with no subfamily" unless @current_subfamily
      #attributes[:incertae_sedis_in] = 'subfamily'
    #elsif !@current_subfamily
      #raise "Genus #{name} has no subfamily"
    #elsif !@current_tribe
      #raise "Genus #{name} has no tribe"
    #end

    #Genus.create! attributes
  #end

end
