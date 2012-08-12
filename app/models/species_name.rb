class SpeciesName < SpeciesGroupName

  def self.get_name data
    data[:species_epithet] || data[:species_group_epithet]
  end

  def self.get_parent_name data
    if data[:subgenus_epithet]
      SubgenusName.import_data data
    elsif data[:genus]
      data[:genus].name
    else
      GenusName.import_data data
    end
  end

  def self.make_import_attributes name, data
    attributes = {
      epithet:      name,
      html_epithet: Formatters::Formatter.italicize(name),
    }
    parent_name = get_parent_name data
    attributes[:name]      = "#{parent_name} #{attributes[:epithet]}"
    attributes[:html_name] = "#{parent_name.to_html} #{attributes[:html_epithet]}"
    attributes
  end

end
