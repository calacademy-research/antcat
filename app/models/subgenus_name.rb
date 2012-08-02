class SubgenusName < GenusGroupName

  def self.get_name data
    data[:subgenus_epithet]
  end

  def self.get_parent_name data
    data[:genus] ? data[:genus].name : GenusName.import_data(data)
  end

  def self.make_attributes name, data
    parent_name = get_parent_name data
    html_epithet = '<i>'.html_safe + name + '</i>'.html_safe
    {
      epithet:      name,
      html_epithet: html_epithet,
      name:         "#{parent_name} (#{name})",
      html_name:    "#{parent_name.to_html} <i>(#{name})</i>",
    }
  end

end
