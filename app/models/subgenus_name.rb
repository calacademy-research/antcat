class SubgenusName < GenusGroupName

  def self.get_name data
    data[:subgenus_epithet]
  end

  def self.get_parent_name data
    data[:genus] ? data[:genus].name : GenusName.import_data(data)
  end

  def self.make_attributes name, data
    parent_name = get_parent_name data
    {
      epithet:      name,
      html_epithet: "<i>#{name}</i>",
      name:         "#{parent_name} (#{name})",
      html_name:    "#{parent_name.to_html} <i>(#{name})</i>",
    }
  end

  def rank
    'subgenus'
  end

end
