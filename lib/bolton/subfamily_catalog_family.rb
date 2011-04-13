class Bolton::SubfamilyCatalog < Bolton::Catalog
  private

  def parse_family
    expect :family_header
    parse_next_line
    skip :other
    expect :family_group_line
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
    expect :genus_header
    parse_genus(:incertae_sedis_in => 'family')  while @type == :genus_header
  end

  def parse_genera_excluded_from_family
    expect :genera_excluded_from_family_header
    parse_next_line
    skip :other
    expect :genus_header
    parse_genus :status => 'excluded' while @type == :genus_header
  end

  def parse_unavailable_family_group_names_in_family
    expect :unavailable_family_group_names_in_family_header
    parse_next_line
    skip :other
  end

  def parse_genus_group_nomina_nuda_in_family
    expect :genus_group_nomina_nuda_in_family_header
    parse_next_line
    expect :genus_header
    parse_genus({:status => 'nomen nudum'}, false) while @type == :genus_header
  end

end
