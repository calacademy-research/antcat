# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private

  def parse_family
    parse_family_header
    parse_family_record
    #parse_family_child_lists
    #parse_family_references
    #parse_family_children
  end

  def parse_family_header
    consume :family_centered_header
    consume :family_header
  end

  def parse_family_record
    headline = consume :family_group_headline
    consume :taxonomic_history_header
    consume :family_taxonomic_history

    Family.import({
      :protonym => {
        :name => headline[:family_or_subfamily_name],
        :authorship => headline[:authorship],
      },
      :type_genus => headline[:type_genus][:genus_name]
    })
  end

  ######################################################
  def parse_family_child_lists
    parse_list :extant_subfamilies_list, ::Subfamily, :subfamilies, :subfamily_name
    parse_list :extinct_subfamilies_list, ::Subfamily, :subfamilies, :subfamily_name, :fossil => true
    parse_list :extant_genera_incertae_sedis_in_family_list, ::Genus, :genera, :genus_name,
               :incertae_sedis_in => 'family'
    parse_list :extinct_genera_incertae_sedis_in_family_list, ::Genus, :genera, :genus_name,
               :incertae_sedis_in => 'family', :fossil => true
    parse_list :extant_genera_excluded_from_family_list, ::Genus, :genera, :genus_name, :status => 'excluded'
    parse_list :extinct_genera_excluded_from_family_list, ::Genus, :genera, :genus_name, :fossil => true, :status => 'excluded'
    parse_genus_group_nomina_nuda_in_family_list
  end

  def parse_list list_type, klass, group_key, name_key, attributes = {}
    attributes = attributes.reverse_merge :status => 'valid'
    expect list_type
    @parse_result[group_key].each do |item|
      klass.create!({:name => item[name_key]}.merge attributes)
    end
    parse_next_line
  end

  def parse_genus_group_nomina_nuda_in_family_list
    expect :genus_group_nomina_nuda_in_family_list
    @parse_result[:genera].each do |genus|
      attributes = {:name => genus[:genus_name], :status => 'nomen nudum'}
      attributes[:fossil] = true if genus[:fossil]
      Genus.create! attributes
    end
    parse_next_line
  end

  ##############################################################
  def parse_family_references
    parse_world_references
    parse_regional_catalogs
    parse_regional_fauna
  end

  def parse_world_references
    consume :family_references_header
    parse_family_reference_sections
  end

  def parse_regional_catalogs
    consume :regional_catalogues_header
    parse_family_reference_sections_with_inline_headings
  end

  def parse_regional_fauna
    consume :regional_and_national_faunas_header
    parse_family_reference_sections
  end

  def parse_family_reference_sections
    while @type == :uppercase_line
      parse_family_reference_section
    end
  end

  def parse_family_reference_sections_with_inline_headings
    while @type != :regional_and_national_faunas_header
      parse_next_line
    end
  end

  def parse_family_reference_section
    parse_next_line :text
    parse_next_line
  end

  ##############################################################
  def parse_family_children
    consume :genera_incertae_sedis_and_exclusions_header
    parse_genera_incertae_sedis_in_family
    parse_genera_excluded_from_family
    parse_unavailable_family_group_names_in_family
    parse_genus_group_nomina_nuda_in_family
  end

  def parse_genera_incertae_sedis_in_family
    consume :genera_incertae_sedis_header
    while parse_genus(:incertae_sedis_in => 'family'); end
  end

  def parse_genera_excluded_from_family
    consume :genera_excluded_from_family_header
    consume :genera_excluded_from_family_note
    while parse_genus(:status => 'excluded'); end
  end

  def parse_unavailable_family_group_names_in_family
    consume :unavailable_family_group_names_header
    parse_unavailable_family_group_name while @type == :unavailable_family_group_name_header
  end

  def parse_unavailable_family_group_name
    return unless @type == :unavailable_family_group_name_header
    loop do
      parse_next_line :unavailable_family_group_name_detail
      break unless @type == :unavailable_family_group_name_detail
    end
  end

  def parse_genus_group_nomina_nuda_in_family
    consume :genus_group_nomina_nuda_header
    while parse_genus({:status => 'nomen nudum'}, :header => :genus_nomen_nudum_header); end
  end

end
