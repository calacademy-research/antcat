class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def parse_family
    expect :family_header
    parse_next_line
    skip :other

    parse_family_summary
    skip :other

    parse_family_detail
  end

  def parse_family_summary
    parse_extant_subfamilies_list
    parse_extinct_subfamilies_list
    parse_extant_genera_incertae_sedis_in_family_list
    parse_extinct_genera_incertae_sedis_in_family_list
    parse_extant_genera_excluded_from_family_list
    parse_extinct_genera_excluded_from_family_list
    parse_genus_group_nomina_nuda_in_family_list
  end

  def parse_family_detail
    parse_genera_incertae_sedis_in_family
    parse_genera_excluded_from_family
    parse_unavailable_family_group_names_in_family
    parse_genus_group_nomina_nuda_in_family
  end

  def parse_extant_subfamilies_list
    expect :extant_subfamilies_list
    @parse_result[:subfamilies].each do |subfamily|
      Subfamily.create! :name => subfamily, :status => 'valid'
    end
    parse_next_line
  end

  def parse_extinct_subfamilies_list
    expect :extinct_subfamilies_list
    @parse_result[:subfamilies].each do |subfamily|
      Subfamily.create! :name => subfamily, :status => 'valid', :fossil => true
    end
    parse_next_line
  end

  def parse_extant_genera_incertae_sedis_in_family_list
    expect :extant_genera_incertae_sedis_in_family_list
    @parse_result[:genera].each do |genus|
      Genus.create! :name => genus, :status => 'valid', :incertae_sedis_in => 'family'
    end
    parse_next_line
  end

  def parse_extinct_genera_incertae_sedis_in_family_list
    expect :extinct_genera_incertae_sedis_in_family_list
    @parse_result[:genera].each do |genus|
      Genus.create! :name => genus, :status => 'valid', :incertae_sedis_in => 'family', :fossil => true
    end
    parse_next_line
  end

  def parse_extant_genera_excluded_from_family_list
    expect :extant_genera_excluded_from_family_list
    @parse_result[:genera].each do |genus|
      Genus.create! :name => genus, :status => 'excluded'
    end
    parse_next_line
  end

  def parse_extinct_genera_excluded_from_family_list
    expect :extinct_genera_excluded_from_family_list
    @parse_result[:genera].each do |genus|
      Genus.create! :name => genus, :status => 'excluded', :fossil => true
    end
    parse_next_line
  end

  def parse_genus_group_nomina_nuda_in_family_list
    expect :genus_group_nomina_nuda_in_family_list
    @parse_result[:genera].each do |genus|
      Genus.create! :name => genus, :status => 'nomen nudum'
    end
    parse_next_line
  end

  def parse_genera_incertae_sedis_in_family
    expect :genera_incertae_sedis_in_family_header
    parse_next_line
    expect :genus
    update_genus(:incertae_sedis_in => 'family')  while @type == :genus
  end

  def parse_genera_excluded_from_family
    expect :genera_excluded_from_family_header
    parse_next_line
    skip :other
    expect :genus
    update_genus(:status => 'excluded') while @type == :genus
  end

  def parse_unavailable_family_group_names_in_family
    expect :unavailable_family_group_names_in_family_header
    parse_next_line
    skip :other
  end

  def parse_genus_group_nomina_nuda_in_family
    expect :genus_group_nomina_nuda_in_family_header
    parse_next_line
    expect :genus
    update_genus(:status => 'nomen nudum') while @type == :genus
  end

  private
  def update_genus attributes
    name = @parse_result[:name]
    status = @parse_result[:status]
    fossil = @parse_result[:fossil]
    taxonomic_history = parse_taxonomic_history
    genus = Genus.find_by_name name
    if genus
      attributes = {:status => status, :taxonomic_history => taxonomic_history}.merge(attributes)
      check_status_change genus, attributes[:status]
      raise "Genus #{name} fossil change from #{genus.fossil?} to #{fossil}" if fossil != genus.fossil
      genus.update_attributes attributes
    else
      check_existence name, genus
      Genus.create!({:name => name, :fossil => fossil, :status => status, :taxonomic_history => taxonomic_history}.merge(attributes))
    end
  end

  def check_status_change genus, status
    raise "Genus #{genus.name} status change from #{genus.status} to #{status}" if status != genus.status unless genus.name == 'Hypochira'
  end

  def check_existence name, genus
    raise "Genus #{name} not found" unless genus || name == 'Syntaphus'
  end
end
