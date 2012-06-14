class SubspeciesName < Name

  def self.get_name data
    data[:subspecies]
  end

  def self.make_attributes _, data
    attributes = {epithet: '', html_epithet: ''}
    for subspecies in data[:subspecies]
      type = subspecies[:type]
      if type
        attributes[:epithet]      << type << ' '
        attributes[:html_epithet] << type << ' '
      end
      epithet = subspecies[:species_group_epithet]
      attributes[:epithet]      << "#{epithet} "
      attributes[:html_epithet] << "<i>#{epithet}</i> "
    end

    attributes[:epithet].strip!
    attributes[:html_epithet].strip!

    parent_name = get_parent_name data
    attributes[:name]      = "#{parent_name} #{attributes[:epithet]}"
    attributes[:html_name] = "#{parent_name.to_html} #{attributes[:html_epithet]}"

    attributes
  end

  def self.get_parent_name data
    data[:species] ? data[:species].name : SpeciesName.import_data(data)
  end

  def rank
    'subspecies'
  end

end
